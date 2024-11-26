import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/package/custom_dialog.dart';
import '../../../core/services/initialization.dart';

class ChickenDensityController extends GetxController {
  MyServices myServices = Get.find();
  final TextEditingController chickensController = TextEditingController();
final Rxn<String> selectedAge = Rxn<String>();
  final RxString areaResult = ''.obs;

  void calculateArea() {
    final int? chickens = int.tryParse(chickensController.text);

    if (chickens == null || selectedAge.value == null || chickens <= 0) {
      areaResult.value = 'يرجى إدخال قيم صحيحة';
      return;
    }

    double recommendedDensity;
    switch (selectedAge.value) {
      case '( 7 - 1 ) الاسبوع الاول':
        recommendedDensity = 30;
        break;
      case '( 14 - 7 ) الاسبوع الثاني':
        recommendedDensity = 25;
        break;
      case '( 21 - 14 ) الاسبوع الثالث':
        recommendedDensity = 20;
        break;
      case '( 28 - 21 ) الاسبوع الرابع':
        recommendedDensity = 15;
        break;
      case '( الي نهاية الدورة ) الاسبوع الخامس':
        recommendedDensity = 10;
        break;
      default:
        recommendedDensity = 0;
    }

    final double requiredArea = chickens / recommendedDensity;
    areaResult.value =
        'المساحة المطلوبة لهذه الفراخ في هذا العمر : \n ${requiredArea.toStringAsFixed(0)} متر مربع';
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
