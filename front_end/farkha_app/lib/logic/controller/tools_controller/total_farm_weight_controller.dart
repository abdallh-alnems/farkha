import 'package:get/get.dart';

class TotalFarmWeightController extends GetxController {
  final RxString birdsCount = ''.obs;
  final RxString birdWeight = ''.obs;
  final RxDouble totalWeight = 0.0.obs;

  void calculate() {
    final int? birds = int.tryParse(birdsCount.value);
    final double? weight = double.tryParse(birdWeight.value);
    if (birds != null && weight != null) {
      totalWeight.value = birds * weight;
    } else {
      totalWeight.value = 0.0;
    }
  }
}
