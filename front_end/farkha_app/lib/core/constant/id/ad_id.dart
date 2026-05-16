import 'dart:io';

import '../../services/test_mode_manager.dart';

class AdManager {
  // ============================ Android production ============================

  static const String _productionBanner =
      'ca-app-pub-8595701567488603/1751748833';
  static const String _productionNative =
      'ca-app-pub-8595701567488603/4494984718';

  // ============================== iOS production ==============================

  static const String _productionBannerIOS =
      'ca-app-pub-8595701567488603/5318059838';
  static const String _productionNativeIOS =
      'ca-app-pub-8595701567488603/4012717023';

  // ================================ Test IDs =================================

  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testNative = 'ca-app-pub-3940256099942544/2247696110';

  // ================================== banner =================================

  static String get idBanner {
    if (TestModeManager.shouldUseTestAds) return _testBanner;
    return Platform.isIOS ? _productionBannerIOS : _productionBanner;
  }

  // ================================== native =================================

  static String get idNative {
    if (TestModeManager.shouldUseTestAds) return _testNative;
    return Platform.isIOS ? _productionNativeIOS : _productionNative;
  }
}
