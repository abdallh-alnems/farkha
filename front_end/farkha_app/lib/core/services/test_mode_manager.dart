class TestModeManager {
  static const bool _isAppInDevelopment = false;

  static const bool _isAdsInTestMode = false;

  static const bool _showTutorialEveryTime = false;

  static bool get shouldUseTestAds => _isAppInDevelopment || _isAdsInTestMode;

  static bool get shouldShowTutorialEveryTime =>
      _isAppInDevelopment || _showTutorialEveryTime;
}
