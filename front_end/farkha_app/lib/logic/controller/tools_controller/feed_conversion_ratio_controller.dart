import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FcrController extends GetxController {
  final double initialWeight =
      0.045; // الوزن الابتدائي الثابت بالكيلوغرام (45 جرام = 0.045 كجم)

  final TextEditingController feedConsumedController = TextEditingController();
  final TextEditingController currentWeightController = TextEditingController();

  RxDouble fcr = 0.0.obs;

  void calculateFCR() {
    final feedConsumed = double.tryParse(feedConsumedController.text) ?? 0;
    final currentWeight = double.tryParse(currentWeightController.text) ?? 0;
    final weightGain = currentWeight - initialWeight;
    if (weightGain > 0) {
      fcr.value = feedConsumed / weightGain;
    } else {
      fcr.value = 0.0;
    }
  }

  /// 0=ممتاز, 1=جيد, 2=مقبول, 3=ضعيف
  int getFcrQuality() {
    final v = fcr.value;
    if (v <= 0) return -1;
    if (v <= 1.6) return 0;
    if (v <= 1.8) return 1;
    if (v <= 1.9) return 2;
    return 3;
  }

  @override
  void onClose() {
    feedConsumedController.dispose();
    currentWeightController.dispose();
    super.onClose();
  }
}
