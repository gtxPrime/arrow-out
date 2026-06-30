import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
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
  BannerAd? _gameBannerAd;
  bool _isGameBannerLoaded = false;

  BannerAd? _homeBannerAd;
  bool _isHomeBannerLoaded = false;

  void initialize() {
    _loadInterstitial();
    _loadRewarded();
    _loadGameBanner();
    _loadHomeBanner();
  }

  // ── Banner ────────────────────────────────────────────────────────────────────

  void _loadGameBanner() {
    _gameBannerAd = BannerAd(
      adUnitId: AppConstants.admobBannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _isGameBannerLoaded = true,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _gameBannerAd = null;
        },
      ),
    )..load();
  }

  void _loadHomeBanner() {
    _homeBannerAd = BannerAd(
      adUnitId: AppConstants.admobBannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _isHomeBannerLoaded = true,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _homeBannerAd = null;
        },
      ),
    )..load();
  }

  BannerAd? get gameBannerAd => _isGameBannerLoaded ? _gameBannerAd : null;
  BannerAd? get homeBannerAd => _isHomeBannerLoaded ? _homeBannerAd : null;
  BannerAd? get bannerAd => gameBannerAd; // Keep for compatibility

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
    final completer = Completer<void>();
    _levelsSinceLastInterstitial = 0;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialLoaded = false;
        _loadInterstitial(); // Pre-load next one
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialLoaded = false;
        _loadInterstitial();
        if (!completer.isCompleted) completer.complete();
      },
    );
    await _interstitialAd!.show();
    return completer.future;
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
    _gameBannerAd?.dispose();
    _homeBannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
