import 'package:get/get.dart';

import '../../../core/functions/number_format.dart';

class TotalFarmWeightController extends GetxController {
  final RxString birdsCount = ''.obs;
  final RxString birdWeight = ''.obs;
  final RxDouble totalWeight = 0.0.obs;


  void calculate() {
    final int? birds = tryParseInt(birdsCount.value);
    final double? weight = tryParseNum(birdWeight.value);
    if (birds != null && weight != null) {
      totalWeight.value = birds * weight;
    } else {
      totalWeight.value = 0.0;
    }
  }
}
