import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../data/data_source/remote/prices_data/last_prices_data.dart';

class LastPricesController extends GetxController {
  late StatusRequest statusRequest;
  LastPricesData lastPricesData = LastPricesData(Get.find());
  List<Map<String, dynamic>> lastPricesList = [];

  getDataLastPrices(String mainId) async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await lastPricesData.getData(mainId);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        lastPricesList = List<Map<String, dynamic>>.from(response['data']);
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}
