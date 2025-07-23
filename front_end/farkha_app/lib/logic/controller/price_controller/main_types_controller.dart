import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../data/data_source/remote/prices_data/main_types_data.dart';

class MainTypesController extends GetxController {
 late StatusRequest statusRequest ;
  MainDataData mainDataData = MainDataData(Get.find());
  List<Map<String, dynamic>> mainTypesList = [];

  Future<void> getDataMainTypes() async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await mainDataData.getData();
    statusRequest = handlingData(response);
    if (statusRequest == StatusRequest.success) {
      if (response['status'] == "success") {
        mainTypesList = List<Map<String, dynamic>>.from(response['data']);
      } else {
        statusRequest = StatusRequest.failure;
      }
    }

    update();
  }

  @override
  void onInit() {
    getDataMainTypes();
    super.onInit();
  }
}
