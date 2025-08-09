import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/package/custom_dialog.dart';
import '../../../core/services/initialization.dart';
import '../../../core/shared/bottom_message.dart';

class ChickenDensityController extends GetxController {
  final MyServices myServices = Get.find();
  final TextEditingController chickenCountTextController =
      TextEditingController();
  final Rxn<String> selectedAgeCategory = Rxn<String>();
  final RxBool shouldDisplayResults = false.obs;
  final RxString currentAgeGroundAreaResult = ''.obs;
  final RxString totalGroundAreaResult = ''.obs;
  final RxString batteryCageAreaResult = ''.obs;

  bool _areInputsValid() {
    return chickenCountTextController.text.isNotEmpty &&
        int.tryParse(chickenCountTextController.text) != null &&
        selectedAgeCategory.value != null;
  }

  void calculateAreas(BuildContext context) {
    if (chickenCountTextController.text.isEmpty ||
        int.tryParse(chickenCountTextController.text) == null) {
      BottomMessage.show(context, 'الرجاء إدخال عدد صحيح');
      shouldDisplayResults.value = false;
      return;
    }

    if (selectedAgeCategory.value == null) {
      BottomMessage.show(context, 'الرجاء اختيار الأسبوع');
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

  void showDialogChickenDensity() {
    DialogHelper.showDialog(
      middleText:
          "هذة الاداة تساعدك علي حساب المساحة المطلوبة لكل عمر \n \n يجب تقسيم العنبر في يوم استقبال الكتاكيت ثم التوسيع تدريجيا لحين تاخذ الفراخ العنبر بالكامل \n \n المساحة المعروضة يجب ان تكون المساحة المخصصة للفراخ فقط دون اماكن تخزين احتياجات الدورة \n \n اذا اردت معرفة عدد الفراخ التي يمكن للعنبر الخاص بك ان يحتويها اضرب مساحة العنبر في 10",
    );
  }

  void checkAndShowDialog() {
    if (myServices.getStorage.read("chickenDensityDialog") != false) {
      showDialogChickenDensity();
      myServices.getStorage.write("chickenDensityDialog", false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowDialog();
    });
  }

  @override
  void onClose() {
    chickenCountTextController.dispose();
    super.onClose();
  }
}
