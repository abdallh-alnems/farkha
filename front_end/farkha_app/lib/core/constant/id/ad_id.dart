class AdManager {
  // ============================ private variables ============================

  static const bool _isTest = true;

  static const String _teatBanner = "ca-app-pub-3940256099942544/6300978111";

  static const String _teatNative = "ca-app-pub-3940256099942544/2247696110";

  // ================================== banner =================================

  static String bannerFirst =
      _isTest ? _teatBanner : "ca-app-pub-8595701567488603/1751748833";

  static String bannerSecond =
      _isTest ? _teatBanner : "ca-app-pub-8595701567488603/1584158060";

  static String bannerThird =
      _isTest ? _teatBanner : "ca-app-pub-8595701567488603/8325394412";

  // ================================== native =================================

  static String nativeFirst =
      _isTest ? _teatNative : "ca-app-pub-8595701567488603/4494984718";

  static String nativeSecond =
      _isTest ? _teatNative : "ca-app-pub-8595701567488603/1075378798";

  static String nativeThird =
      _isTest ? _teatNative : "ca-app-pub-8595701567488603/1164528612";
}
