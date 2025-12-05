import '../../services/test_mode_manager.dart';

class AdManager {
  // ============================ private variables ============================

  static const String _productionBanner =
      "ca-app-pub-8595701567488603/1751748833";
  static const String _productionNative =
      "ca-app-pub-8595701567488603/4494984718";

  // ================================ Test IDs =================================

  static const String _testBanner = "ca-app-pub-3940256099942544/6300978111";
  static const String _testNative = "ca-app-pub-3940256099942544/2247696110";

  // ================================== banner =================================

  static String get idBanner =>
      TestModeManager.shouldUseTestAds ? _testBanner : _productionBanner;

  // ================================== native =================================

  static String get idNative =>
      TestModeManager.shouldUseTestAds ? _testNative : _productionNative;
}
