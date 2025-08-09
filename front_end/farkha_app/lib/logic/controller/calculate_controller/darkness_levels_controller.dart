import 'package:get/get.dart';
import '../../../data/data_source/static/growth_parameters.dart';

class DarknessLevelsController extends GetxController {
  final RxInt selectedDay = 1.obs;

  int get maxDay => darknessLevels.length;
  int get darkness => darknessLevels[selectedDay.value - 1];

  void setDay(int day) => selectedDay.value = day;
}
