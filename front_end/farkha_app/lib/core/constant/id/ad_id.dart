class AdManager {
  static bool isTest = false;

  //================================== banner ==================================

  static String bannerFirst = isTest
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-8595701567488603/1751748833";

  static String bannerSecond = isTest
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-8595701567488603/1584158060";

  static String bannerThird = isTest
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-8595701567488603/8325394412";

  //================================== native ==================================

  static String nativeFirst = isTest
      ? "ca-app-pub-3940256099942544/2247696110"
      : "ca-app-pub-8595701567488603/4494984718";

  static String nativeSecond = isTest
      ? "ca-app-pub-3940256099942544/2247696110"
      : "ca-app-pub-8595701567488603/1075378798";

  static String nativeThird = isTest
      ? "ca-app-pub-3940256099942544/2247696110"
      : "ca-app-pub-8595701567488603/1164528612";
}
