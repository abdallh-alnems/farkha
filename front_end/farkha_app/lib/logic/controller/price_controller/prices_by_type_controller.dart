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
    final response = await pricesByTypesData.getData(mainId);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      final mapResponse = response as Map<String, dynamic>;
      if (mapResponse['status'] == 'success') {
        final data = mapResponse['data'] as List<dynamic>;
        pricesByTypeList = data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}
