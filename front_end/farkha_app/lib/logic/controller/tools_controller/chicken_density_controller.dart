import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/id/tool_ids.dart';
import '../../../core/services/initialization.dart';
import '../../../core/shared/snackbar_message.dart';
import 'tool_usage_controller.dart';

class ChickenDensityController extends GetxController {
  static const int toolId =
      ToolIds.chickenDensity; // Chicken Density tool ID = 3

  final MyServices myServices = Get.find();
  final TextEditingController chickenCountTextController =
      TextEditingController();
  final Rxn<String> selectedAgeCategory = Rxn<String>();
  final RxBool shouldDisplayResults = false.obs;
  final RxString currentAgeGroundAreaResult = ''.obs;
  final RxString totalGroundAreaResult = ''.obs;
  final RxString batteryCageAreaResult = ''.obs;

  void calculateAreas(BuildContext context) {
    if (chickenCountTextController.text.isEmpty ||
        int.tryParse(chickenCountTextController.text) == null) {
      SnackbarMessage.show(context, 'الرجاء إدخال عدد صحيح', icon: Icons.error);
      shouldDisplayResults.value = false;
      return;
    }

    if (selectedAgeCategory.value == null) {
      SnackbarMessage.show(context, 'الرجاء اختيار الأسبوع', icon: Icons.error);
      shouldDisplayResults.value = false;
      return;
    }

    shouldDisplayResults.value = true;
    final chickenCount = int.tryParse(chickenCountTextController.text) ?? 0;
    final recommendedDensity = _getRecommendedDensity(
      selectedAgeCategory.value!,
    );

    final requiredGroundArea = (chickenCount / recommendedDensity).clamp(
      1,
      double.infinity,
    );
    final totalArea = (chickenCount / 10).clamp(1, double.infinity);
    final requiredBatteryCageArea = (chickenCount / 16).clamp(
      1,
      double.infinity,
    );

    currentAgeGroundAreaResult.value =
        'المساحة المطلوبة في عمر $selectedAgeCategory: ${requiredGroundArea.toStringAsFixed(0)}م';
    totalGroundAreaResult.value =
        'المساحة الكلية حتى عمر البيع: ${totalArea.toStringAsFixed(0)}م';
    batteryCageAreaResult.value =
        'المساحة المطلوبة للتربية في البطاريات: ${requiredBatteryCageArea.toStringAsFixed(0)}م';
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
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
  }

  @override
  void onClose() {
    chickenCountTextController.dispose();
    super.onClose();
  }
}
