import 'package:get/get.dart';

import '../../../data/data_source/remote/prices_data/main_types_data.dart';
import '../base/base_list_controller.dart';

class MainTypesController extends BaseListController {
  MainDataData mainDataData = MainDataData(Get.find());

  @override
  Future<dynamic> fetchData() => mainDataData.getData();

  @override
  void onInit() {
    load();
    super.onInit();
  }
}
