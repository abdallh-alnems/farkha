import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/package/custom_dialog.dart';
import '../../../core/services/initialization.dart';

class ChickenDensityController extends GetxController {
  final MyServices myServices = Get.find();
  final TextEditingController textController = TextEditingController();
  final Rxn<String> selectedAge = Rxn<String>();
  final RxString areaResult = 'ادخل العدد والعمر'.obs;

  ChickenDensityController() {
    textController.addListener(() {
      if (_areInputsValid()) {
        calculateArea();
      }
    });
  }

  bool _areInputsValid() {
    return textController.text.isNotEmpty &&
        int.tryParse(textController.text) != null &&
        selectedAge.value != null;
  }

  void calculateArea() {
    final int? chickens = int.tryParse(textController.text);

    int recommendedDensity = _getRecommendedDensity(selectedAge.value!);
    final double requiredArea =
        (chickens! / recommendedDensity).clamp(1, double.infinity);

    areaResult.value =
        'المساحة المطلوبة  لعدد ${textController.text} فرخ في عمر $selectedAge هي : \n ${requiredArea.toStringAsFixed(0)} متر مربع';
  }

  int _getRecommendedDensity(String age) {
    switch (age) {
      case 'الاسبوع الاول':
        return 30;
      case 'الاسبوع الثاني':
        return 25;
      case 'الاسبوع الثالث':
        return 20;
      case 'الاسبوع الرابع':
        return 15;
      case 'الاسبوع الخامس':
        return 10;
      default:
        return 0;
    }
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
}
