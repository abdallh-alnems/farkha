import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../data/data_source/remote/prices_data/farkh_abid_data.dart';

class FarkhAbidController extends GetxController {
  String todayPrice = '';
  String yesterdayPrice = '';

  late StatusRequest statusRequest;
  FarkhAbidData farkhAbidData = FarkhAbidData(Get.find());

  getDataFarkhAbid() async {
    statusRequest = StatusRequest.loading;
    var response = await farkhAbidData.getData();
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List data = response['data'];
        todayPrice = data[0]['price'].toString();
        yesterdayPrice = data[1]['price'].toString();
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  @override
  void onInit() {
    getDataFarkhAbid();
    super.onInit();
  }
}
