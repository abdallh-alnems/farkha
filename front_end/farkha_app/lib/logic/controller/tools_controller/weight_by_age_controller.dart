import 'package:get/get.dart';
import '../../../data/data_source/static/growth_parameters.dart';

class WeightByAgeController extends GetxController {
  RxInt selectedAge = 1.obs;
  RxInt weight = 0.obs;

  void calculateWeight() {
    if (selectedAge.value > 0 && selectedAge.value <= weightsList.length) {
      weight.value = weightsList[selectedAge.value - 1];
    } else {
      weight.value = 0;
    }
  }
}
