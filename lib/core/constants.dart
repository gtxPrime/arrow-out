// Core game constants
class AppConstants {
  AppConstants._();

  // App identity
  static const String appName = 'Arrow Out';
  static const String packageId = 'com.gxdevs.arrowout';

  // Grid — starts at 6×6 from level 1 (tutorial levels 1-3 only)
  static const int tutorialLevels = 3;
  static const int startingGridSize = 6;
  static const int maxGridSize = 10;

  // Lives — 3 per game, reset on level restart, restore on rewarded ad
  static const int maxLives = 3;
  // No timer refill — only restored via rewarded ad or level restart

  // Special levels
  static const int bossLevelEvery = 3;   // Every 3rd level is BOSS
  static const int godLevelEvery = 5;    // Every 5th level is GOD (overrides boss)

  // Ads (Test IDs — replace before publishing)
  static const String admobAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const String admobBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String admobInterstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String admobRewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Unity Ads (Replace before publishing)
  static const String unityGameId = 'YOUR_UNITY_GAME_ID';
  static const String unityRewardedAdId = 'Rewarded_Android';
  static const bool unityTestMode = true;

  // Interstitial — every N normal levels (boss/god levels don't count)
  static const int interstitialEveryNLevels = 4;

  // Animation durations
  static const Duration arrowSlideDuration = Duration(milliseconds: 220);
  static const Duration arrowExitDuration = Duration(milliseconds: 350);
  static const Duration arrowShakeDuration = Duration(milliseconds: 400);
  static const Duration levelCompleteDuration = Duration(milliseconds: 600);

  // Scoring
  static const int baseScore = 100;
  static const int bonusPerRemainingLife = 50;
  static const int bossBonus = 200;
  static const int godBonus = 500;

  // Streak milestones (days)
  static const int streakMilestone1 = 7;
  static const int streakMilestone2 = 30;
  static const int streakMilestone3 = 100;

  /// Grid size for a given level number:
  /// Levels 1-3  → 6×6 (tutorial)
  /// Levels 4-20 → 6×6
  /// Levels 21-50 → 7×7
  /// Levels 51-100 → 7×7
  /// Levels 101-200 → 8×8
  /// Levels 201-400 → 9×9
  /// Levels 401+    → 10×10
  static int gridSizeForLevel(int level) {
    if (level <= 20)  return 6;
    if (level <= 50)  return 7;
    if (level <= 100) return 7;
    if (level <= 200) return 8;
    if (level <= 400) return 9;
    return 10;
  }

  /// Returns the level type: tutorial, god, boss, or normal
  static LevelType levelTypeFor(int level) {
    if (level <= tutorialLevels) return LevelType.tutorial;
    if (level % godLevelEvery == 0) return LevelType.god;
    if (level % bossLevelEvery == 0) return LevelType.boss;
    return LevelType.normal;
  }
}

enum LevelType {
  tutorial,
  normal,
  boss,
  god;

  String get label {
    switch (this) {
      case LevelType.tutorial: return 'Tutorial';
      case LevelType.normal:   return '';
      case LevelType.boss:     return '⚡ Boss';
      case LevelType.god:      return '🔥 God';
    }
  }

  bool get isSpecial => this == LevelType.boss || this == LevelType.god;
}
