class TestModeManager {
  static const bool _isAppInDevelopment = false;

  static const bool _isAdsInTestMode = true;

  static const bool _alwaysShowReviewPrompt = false;

  static const bool _alwaysShowCycleFeedback = false;

  static const bool _adsDisabled = false;

  static const bool _alwaysShowStoreRatePrompt = false;

  static bool get shouldDisableAds => _adsDisabled;

  static bool get shouldUseTestAds => _isAppInDevelopment || _isAdsInTestMode;

  static bool get shouldAlwaysShowReviewPrompt =>
      _isAppInDevelopment || _alwaysShowReviewPrompt;

  static bool get shouldAlwaysShowCycleFeedback =>
      _isAppInDevelopment || _alwaysShowCycleFeedback;

  static bool get shouldAlwaysShowStoreRatePrompt =>
      _isAppInDevelopment || _alwaysShowStoreRatePrompt;
}
