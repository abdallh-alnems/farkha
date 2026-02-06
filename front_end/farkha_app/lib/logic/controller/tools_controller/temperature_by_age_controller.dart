import 'package:get/get.dart';

import '../../../data/data_source/static/chicken_data.dart';

class TemperatureByAgeController extends GetxController {
  Rx<int?> selectedAge = Rx<int?>(null);
  RxInt temperature = 0.obs;


  void calculateTemperature() {
    if (selectedAge.value != null &&
        selectedAge.value! > 0 &&
        selectedAge.value! <= temperatureList.length) {
      temperature.value = temperatureList[selectedAge.value! - 1];
    } else {
      temperature.value = 0;
    }
  }
}
