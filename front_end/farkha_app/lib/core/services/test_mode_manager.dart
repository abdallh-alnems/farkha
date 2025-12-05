class TestModeManager {
  static const bool _isAppInDevelopment = false;

  static const bool _isAdsInTestMode = true;

  static const bool _disableToolUsageTracking = true;

  static const bool _showTutorialEveryTime = false;

  static bool get shouldUseTestAds => _isAppInDevelopment || _isAdsInTestMode;

  static bool get canSendToolUsageData =>
      !_disableToolUsageTracking && !_isAppInDevelopment;

  static bool get shouldShowTutorialEveryTime =>
      _isAppInDevelopment || _showTutorialEveryTime;
}
