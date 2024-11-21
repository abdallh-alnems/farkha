import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../data/data_source/remote/prices_data/last_prices_data.dart';
import '../../../data/model/last_prices_model.dart';

class LastPricesController extends GetxController {
  late StatusRequest statusRequest;
  LastPricesData lastPricesData = LastPricesData(Get.find());
  List<LastPricesModel> pricesList = [];

  getDataLastPrices() async {
    statusRequest = StatusRequest.loading;
    var response = await lastPricesData.getData();
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List data = response['data'];
        pricesList.addAll(data.map((e) => LastPricesModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  @override
  void onInit() {
    getDataLastPrices();
    super.onInit();
  }
}
