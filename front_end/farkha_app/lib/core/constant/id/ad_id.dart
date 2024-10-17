class AdManager {
  static bool isTest = false;

  //================================== banner ==================================

  static String bannerHome = isTest
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-8595701567488603/1584158060";

  static String bannerAll = isTest
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-8595701567488603/1751748833";

  //================================== native ==================================

  static String nativeHome = isTest
      ? "ca-app-pub-3940256099942544/2247696110"
      : "ca-app-pub-8595701567488603/1075378798";

  static String nativeAll = isTest
      ? "ca-app-pub-3940256099942544/2247696110"
      : "ca-app-pub-8595701567488603/4494984718";
}
