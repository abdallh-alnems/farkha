import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../../core/constant/routes/route.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/services/initialization.dart';
import '../../logic/controller/auth/login_controller.dart';
import '../../logic/controller/cycle_controller.dart';

class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;

  Future<DeepLinkService> init() async {
    _appLinks = AppLinks();

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (Object err) {},
    );

    return this;
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'farkha' && uri.host == 'join') {
      final code = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (code.isNotEmpty) {
        _joinCycleByCode(code);
      }
    } else if (uri.scheme == 'https' && uri.path.contains('join')) {
      final code = uri.queryParameters['code'] ?? '';
      if (code.isNotEmpty) {
        _joinCycleByCode(code);
      }
    }
  }

  void _joinCycleByCode(String code) {
    Future.delayed(const Duration(milliseconds: 500), () {
      final loginCtrl = Get.isRegistered<LoginController>()
          ? Get.find<LoginController>()
          : null;

      final isLoggedIn = loginCtrl?.isLoggedIn.value == true ||
          (Get.isRegistered<MyServices>() &&
              Get.find<MyServices>()
                  .getStorage
                  .read<bool>(StorageKeys.isLoggedIn) ==
                  true);

      if (isLoggedIn) {
        _executeJoin(code);
      } else {
        final myServices = Get.find<MyServices>();
        myServices.getStorage.write(StorageKeys.pendingJoinCode, code);
        Get.toNamed<void>(AppRoute.login);
      }
    });
  }

  void _executeJoin(String code) {
    final cycleCtrl = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : Get.put(CycleController());
    cycleCtrl.joinByCode(code);
  }

  static void consumePendingJoinCode() {
    final myServices = Get.find<MyServices>();
    final code = myServices.getStorage.read<String>(StorageKeys.pendingJoinCode);
    if (code == null || code.isEmpty) return;

    myServices.getStorage.remove(StorageKeys.pendingJoinCode);

    final cycleCtrl = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : Get.put(CycleController());
    cycleCtrl.joinByCode(code);
  }
}
