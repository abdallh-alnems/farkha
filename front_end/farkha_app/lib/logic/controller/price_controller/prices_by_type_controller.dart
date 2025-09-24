import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../data/data_source/remote/prices_data/prices_by_type.dart';

class PricesByTypeController extends GetxController {
  late StatusRequest statusRequest;
  PricesByTypeData pricesByTypesData = PricesByTypeData(Get.find());
  List<Map<String, dynamic>> pricesByTypeList = [];

  Future<void> getDataPricesByType(String mainId) async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await pricesByTypesData.getData(mainId);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      final mapResponse = response as Map<String, dynamic>;
      if (mapResponse['status'] == "success") {
       pricesByTypeList = List<Map<String, dynamic>>.from(mapResponse['data']);
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}
