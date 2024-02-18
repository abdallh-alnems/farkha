import 'package:get/get.dart';
import '../../core/class/status_request.dart';
import '../../core/functions/handingdatacontroller.dart';
import '../../data/data_source/remote/home_data.dart';
import '../../data/model/home_model.dart';

abstract class HomeController extends GetxController {
  getData();
}

class HomeControllerImp extends HomeController {
  List<HomeModel> data = [];

  HomeData homeData = HomeData(Get.find());

  late StatusRequest statusRequest;

  @override
  getData() async {
    statusRequest = StatusRequest.loading;
    var response = await homeData.getData();
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List responseData = response['data'];
        data.addAll(responseData.map((e) => HomeModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
