import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants.dart';

/// Central ad orchestrator — manages banner, interstitial, and rewarded ads.
/// Uses AdMob as primary with Unity Ads as waterfall fallback.
class AdManager {
  // ── Interstitial ─────────────────────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  int _levelsSinceLastInterstitial = 0;

  // ── Rewarded ─────────────────────────────────────────────────────────────────
  RewardedAd? _rewardedAd;
  bool _isRewardedLoaded = false;

  // ── Banner ────────────────────────────────────────────────────────────────────
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  void initialize() {
    _loadInterstitial();
    _loadRewarded();
    _loadBanner();
  }

  // ── Banner ────────────────────────────────────────────────────────────────────

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.admobBannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _isBannerLoaded = true,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  BannerAd? get bannerAd => _isBannerLoaded ? _bannerAd : null;

  // ── Interstitial ──────────────────────────────────────────────────────────────

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AppConstants.admobInterstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  /// Call after each level complete. Shows interstitial every N normal levels.
  Future<void> onLevelComplete(int levelNumber, bool isSpecialLevel) async {
    if (isSpecialLevel) return; // No ads on boss/god levels
    _levelsSinceLastInterstitial++;
    if (_levelsSinceLastInterstitial >= AppConstants.interstitialEveryNLevels) {
      await showInterstitial();
    }
  }

  Future<void> showInterstitial() async {
    if (!_isInterstitialLoaded || _interstitialAd == null) return;
    _levelsSinceLastInterstitial = 0;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialLoaded = false;
        _loadInterstitial(); // Pre-load next one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialLoaded = false;
        _loadInterstitial();
      },
    );
    await _interstitialAd!.show();
  }

  // ── Rewarded ──────────────────────────────────────────────────────────────────

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AppConstants.admobRewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoaded = false;
        },
      ),
    );
  }

  bool get isRewardedAvailable => _isRewardedLoaded && _rewardedAd != null;

  /// Show rewarded ad. Calls [onRewarded] if user earns the reward.
  Future<void> showRewarded({
    required void Function() onRewarded,
    void Function()? onDismissed,
  }) async {
    if (!isRewardedAvailable) {
      onDismissed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedLoaded = false;
        _loadRewarded();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedLoaded = false;
        _loadRewarded();
        onDismissed?.call();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) => onRewarded(),
    );
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
