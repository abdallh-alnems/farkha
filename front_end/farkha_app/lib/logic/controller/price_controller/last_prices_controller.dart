import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../data/data_source/remote/prices_data/last_prices_data.dart';

class LastPricesController extends GetxController {
  late StatusRequest statusRequest;
  LastPricesData lastPricesData = LastPricesData(Get.find());
  List<Map<String, dynamic>> lastPricesList = [];

  Future<void> getDataLastPrices(String mainId) async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await lastPricesData.getData(mainId);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      final mapResponse = response as Map<String, dynamic>;
      if (mapResponse['status'] == "success") {
        lastPricesList = List<Map<String, dynamic>>.from(mapResponse['data']);
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}
