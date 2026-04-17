import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../logic/controller/cycle_controller.dart';

/// خدمة معالجة الروابط العميقة
/// Deep Link Service - handles farkha://join/CODE links
class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;

  Future<DeepLinkService> init() async {
    _appLinks = AppLinks();

    // Handle initial link (app was closed)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // Handle links while app is running
    _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (Object err) {
        debugPrint('Deep link error: $err');
      },
    );

    debugPrint('✅ DeepLinkService initialized');
    return this;
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('📎 Deep link received: $uri');

    // Handle: farkha://join/CODE
    if (uri.scheme == 'farkha' && uri.host == 'join') {
      final code = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (code.isNotEmpty) {
        _joinCycleByCode(code);
      }
    }
  }

  void _joinCycleByCode(String code) {
    debugPrint('🔗 Joining cycle with code: $code');

    // Wait a moment for app to be ready
    Future.delayed(const Duration(milliseconds: 500), () {
      final cycleCtrl =
          Get.isRegistered<CycleController>()
              ? Get.find<CycleController>()
              : Get.put(CycleController());
      cycleCtrl.joinByCode(code);
    });
  }
}
