import 'package:get/get.dart';

import '../../../data/data_source/static/chicken_data.dart';

class WeightByAgeController extends GetxController {
  Rx<int?> selectedAge = Rx<int?>(null);
  RxInt weight = 0.obs;

  void calculateWeight() {
    if (selectedAge.value != null &&
        selectedAge.value! > 0 &&
        selectedAge.value! <= weightsList.length) {
      weight.value = weightsList[selectedAge.value! - 1];
    } else {
      weight.value = 0;
    }
  }
}
