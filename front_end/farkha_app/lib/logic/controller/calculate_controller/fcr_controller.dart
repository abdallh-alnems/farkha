import 'package:get/get.dart';

class FcrController extends GetxController {
  final double initialWeight =
      0.045; // الوزن الابتدائي الثابت بالكيلوغرام (45 جرام = 0.045 كجم)

  RxDouble feedConsumed = 0.0.obs; // كمية العلف المستهلك (كجم)
  RxDouble currentWeight = 0.0.obs; // الوزن الحالي للقطيع (كجم)
  RxDouble fcr = 0.0.obs; // الناتج

  void calculateFCR() {
    double weightGain = currentWeight.value - initialWeight;
    if (weightGain > 0) {
      fcr.value = feedConsumed.value / weightGain;
    } else {
      fcr.value = 0.0;
    }
  }
}
