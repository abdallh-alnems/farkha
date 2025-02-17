class AdManager {
  // ============================ private variables ============================

  static const bool _isTest = true;

  static const String _testBanner = "ca-app-pub-3940256099942544/6300978111";
  static const String _testNative = "ca-app-pub-3940256099942544/2247696110";

  // ================================== banner =================================

  static String get bannerFirst =>
      _isTest ? _testBanner : "ca-app-pub-8595701567488603/1751748833";

  static String get bannerSecond =>
      _isTest ? _testBanner : "ca-app-pub-8595701567488603/1584158060";

  static String get bannerThird =>
      _isTest ? _testBanner : "ca-app-pub-8595701567488603/8325394412";

  // ================================== native =================================

  static String get nativeFirst =>
      _isTest ? _testNative : "ca-app-pub-8595701567488603/4494984718";

  static String get nativeSecond =>
      _isTest ? _testNative : "ca-app-pub-8595701567488603/1075378798";
      

  static String get nativeThird =>
      _isTest ? _testNative : "ca-app-pub-8595701567488603/1164528612";
}
