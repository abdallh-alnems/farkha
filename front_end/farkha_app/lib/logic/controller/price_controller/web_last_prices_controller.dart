import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../data/data_source/remote/prices_data/web_last_prices_data.dart';

class WebListPricesController extends GetxController {
  late StatusRequest statusRequest;
  WebListPricesData webListPricesData = WebListPricesData(Get.find());
  List<Map<String, dynamic>> webListPricesList = [];

  Future<void> getDataMainTypes() async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await webListPricesData.getData();
    statusRequest = handlingData(response);
    if (statusRequest == StatusRequest.success) {
      if (response['status'] == "success") {
        webListPricesList = List<Map<String, dynamic>>.from(response['data']);
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
