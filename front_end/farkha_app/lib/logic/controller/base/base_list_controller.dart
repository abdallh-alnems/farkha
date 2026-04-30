import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/functions/handling_data_controller.dart';

abstract class BaseListController extends GetxController {
  StatusRequest statusRequest = StatusRequest.none;
  List<Map<String, dynamic>> items = [];

  Future<dynamic> fetchData();

  Future<void> load() async {
    statusRequest = StatusRequest.loading;
    update();

    final response = await fetchData();
    statusRequest = handlingData(response);

    if (statusRequest == StatusRequest.success) {
      final mapResponse = response as Map<String, dynamic>;
      if (mapResponse['status'] == 'success') {
        items =
            (mapResponse['data'] as List).cast<Map<String, dynamic>>();
      } else {
        statusRequest = StatusRequest.failure;
      }
    }

    update();
  }
}
