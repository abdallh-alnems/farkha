import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../data/data_source/remote/prices_data/feed_prices_data.dart';

class FeedPricesController extends GetxController {
  late StatusRequest statusRequest;
  FeedPricesData feedPricesData = FeedPricesData(Get.find());
  List<Map<String, dynamic>> feedPricesList = [];

  Future<void> getDataFeedPrices(String mainId) async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await feedPricesData.getData(mainId);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      final mapResponse = response as Map<String, dynamic>;
      if (mapResponse['status'] == "success") {
        feedPricesList = List<Map<String, dynamic>>.from(mapResponse['data']);
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}
