import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/package/custom_dialog.dart';
import '../../../core/services/initialization.dart';

class ChickenDensityController extends GetxController {
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  final MyServices myServices = Get.find();
  final TextEditingController chickensController = TextEditingController();
  final Rxn<String> selectedAge = Rxn<String>();
  final RxString areaResult = 'ادخل العدد والعمر'.obs;

  ChickenDensityController() {
    chickensController.addListener(() {
      if (_areInputsValid()) {
        calculateArea();
      }
    });
  }

  bool _areInputsValid() {
    return chickensController.text.isNotEmpty && selectedAge.value != null;
  }

  void calculateArea() {
    final int? chickens = int.tryParse(chickensController.text);

    double recommendedDensity = _getRecommendedDensity(selectedAge.value!);
    final double requiredArea = chickens! / recommendedDensity;

    areaResult.value =
        'المساحة المطلوبة لهذه الفراخ في هذا العمر : \n ${requiredArea.toStringAsFixed(0)} متر مربع';
  }

  double _getRecommendedDensity(String age) {
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
