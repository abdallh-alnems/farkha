import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../data/data_source/remote/farkh_abid_data.dart';
import '../../../data/model/farkh_abid_model.dart';

class FarkhAbidController extends GetxController {
  String todayPrice = '';
  String yesterdayPrice = '';

  late StatusRequest statusRequest;
  FarkhAbidData farkhAbidData = FarkhAbidData(Get.find());

  @override
  void onInit() {
    getDataFarkhAbid();
    super.onInit();
  }

  getDataFarkhAbid() async {
    statusRequest = StatusRequest.loading;
    var response = await farkhAbidData.getData();
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        var data = response['data'];
        List<FarkhAbidModel> farkhAbidList = data
            .map<FarkhAbidModel>((json) => FarkhAbidModel.fromJson(json))
            .toList();
        todayPrice = farkhAbidList[0].price.toString();
        yesterdayPrice = farkhAbidList[1].price.toString();
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}
