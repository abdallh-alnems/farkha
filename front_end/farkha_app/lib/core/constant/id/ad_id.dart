class AdManager {
  // ============================ private variables ============================

  static const bool _isTest = false;

  static const String _testBanner = "ca-app-pub-3940256099942544/6300978111";
  static const String _testNative = "ca-app-pub-3940256099942544/2247696110";

  // ================================== banner =================================

  static String get idBanner =>
      _isTest ? _testBanner : "ca-app-pub-8595701567488603/1751748833";

  // ================================== native =================================

  static String get idNative =>
      _isTest ? _testNative : "ca-app-pub-8595701567488603/4494984718";
}
