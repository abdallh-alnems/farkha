import 'package:get/get.dart';
import '../../../data/data_source/static/growth_parameters.dart';

class TemperatureByAgeController extends GetxController {
  RxInt selectedAge = 1.obs;
  RxInt temperature = 0.obs;

  void calculateTemperature() {
    if (selectedAge.value > 0 && selectedAge.value <= temperatureList.length) {
      temperature.value = temperatureList[selectedAge.value - 1];
    } else {
      temperature.value = 0;
    }
  }
}
