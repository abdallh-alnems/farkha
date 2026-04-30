import 'package:get/get.dart';

import '../../core/class/crud.dart';
import '../../core/package/rating_app.dart';
import '../../core/services/permission.dart';
import '../controller/internet_controller.dart';
import '../controller/tools_controller/favorite_tools_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud());
    Get.put(PermissionController(), permanent: true);
    Get.put(InternetController(), permanent: true);
    Get.put(RateMyAppController(), permanent: true);
    Get.put(FavoriteToolsController(), permanent: true);
  }
}
