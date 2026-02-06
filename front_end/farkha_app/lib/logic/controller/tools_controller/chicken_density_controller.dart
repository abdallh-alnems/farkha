import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/functions/number_format.dart';
import '../../../core/services/initialization.dart';

class ChickenDensityController extends GetxController {
  final MyServices myServices = Get.find();
  final TextEditingController chickenCountTextController =
      TextEditingController();
  final Rxn<String> selectedAgeCategory = Rxn<String>();
  final RxBool shouldDisplayResults = false.obs;
  final RxString currentAgeGroundAreaResult = ''.obs;
  final RxString totalGroundAreaResult = ''.obs;
  final RxString batteryCageAreaResult = ''.obs;

  void calculateAreas() {
    if (chickenCountTextController.text.isEmpty ||
        int.tryParse(chickenCountTextController.text) == null) {
      shouldDisplayResults.value = false;
      return;
    }

    if (selectedAgeCategory.value == null) {
      shouldDisplayResults.value = false;
      return;
    }

    shouldDisplayResults.value = true;
    final chickenCount = int.tryParse(chickenCountTextController.text) ?? 0;
    final recommendedDensity = _getRecommendedDensity(
      selectedAgeCategory.value!,
    );

    final requiredGroundArea = (chickenCount / recommendedDensity)
        .clamp(1, double.infinity)
        .toDouble();
    final totalArea = (chickenCount / 10).clamp(1, double.infinity).toDouble();
    final requiredBatteryCageArea = (chickenCount / 16)
        .clamp(1, double.infinity)
        .toDouble();

    final weekName = selectedAgeCategory.value!;
    currentAgeGroundAreaResult.value =
        'المساحة حسب العمر ($weekName): ${formatDecimal(requiredGroundArea, decimals: 0)} م²';
    totalGroundAreaResult.value =
        'المساحة الكلية حتى عمر البيع: ${formatDecimal(totalArea, decimals: 0)} م²';
    batteryCageAreaResult.value =
        '${formatDecimal(requiredBatteryCageArea, decimals: 0)} م²';
  }

  int _getRecommendedDensity(String age) {
    const densityMap = {
      'الاسبوع الاول': 30,
      'الاسبوع الثاني': 25,
      'الاسبوع الثالث': 20,
      'الاسبوع الرابع': 15,
      'الاسبوع الخامس': 10,
    };
    return densityMap[age] ?? 0;
  }


  @override
  void onClose() {
    chickenCountTextController.dispose();
    super.onClose();
  }
}
