import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../core/package/custom_dialog.dart';
import '../../../core/services/initialization.dart';
import '../../../data/data_source/remote/feasibility_study_data.dart';

class FeasibilityController extends GetxController {
  MyServices myServices = Get.find();
  late StatusRequest statusRequest = StatusRequest.none;
  final TextEditingController countChickens = TextEditingController();
  FeasibilityData feasibilityData = FeasibilityData(Get.find());

  late int chickenSalePrice;
  late int chickPrice;
  late int badiPrice;
  late int namiPrice;
  late int nahiPrice;

  RxString mortalityResult = "".obs;
  RxString chickenCostResult = "".obs;
  RxString feedCostResult = "".obs;
  RxString overheadCostResult = "".obs;
  RxString totalCostResult = "".obs;
  RxString salesResult = "".obs;
  RxString profitResult = "".obs;

  Future<void> fetchFeasibilityData() async {
    try {
      statusRequest = StatusRequest.loading;
      update();

      var response = await feasibilityData.getData();
      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        if (response['status'] == "success") {
          List data = response['data'];

          chickenSalePrice = data[0]['price'];
          chickPrice = data[1]['price'];
          badiPrice = data[2]['price'];
          namiPrice = data[3]['price'];
          nahiPrice = data[4]['price'];

          statusRequest = StatusRequest.success;
        } else {
          statusRequest = StatusRequest.failure;
        }
      }
      update();
    } catch (e) {
      statusRequest = StatusRequest.failure;
      update();
    }
  }

  void calculateFeasibility() async {
    try {
      if (statusRequest != StatusRequest.success) {
        await fetchFeasibilityData();
        if (statusRequest != StatusRequest.success) {
          return;
        }
      }

      int count = int.parse(countChickens.text);

      const double mortalityRate = 0.05;
      const double badiConsumption = 0.5;
      const double namiConsumption = 1.2;
      const double nahiConsumption = 1.8;
      const int overheadPerChicken = 10;
      const double averageWeight = 2.3;

      int deadChickens = (count * mortalityRate).round();
      int remainingChickens = count - deadChickens;

      int totalChickenPrice = count * chickPrice;

      double badiCost = badiConsumption * (badiPrice / 1000);
      double namiCost = namiConsumption * (namiPrice / 1000);
      double nahiCost = nahiConsumption * (nahiPrice / 1000);

      double totalFeedCost = (badiCost + namiCost + nahiCost) * count;

      int totalOverheadCost = count * overheadPerChicken;

      double totalCost = totalChickenPrice + totalFeedCost + totalOverheadCost;

      double totalSales = remainingChickens * averageWeight * chickenSalePrice;

      double profit = totalSales - totalCost;

      mortalityResult.value = "النافق : $deadChickens فراخ";
      chickenCostResult.value = "سعر الكتاكيت : $totalChickenPrice ج";
      feedCostResult.value =
          "تكلفة العلف : ${totalFeedCost.toStringAsFixed(0)} ج";
      overheadCostResult.value = "النثريات : $totalOverheadCost ج";
      totalCostResult.value =
          "التكلفة الإجمالية: ${totalCost.toStringAsFixed(0)} ج";
      salesResult.value = "إجمالي المبيعات: ${totalSales.toStringAsFixed(0)} ج";
      profitResult.value = "الأرباح: ${profit.toStringAsFixed(0)} ج";

      update();
    } catch (e) {
      mortalityResult.value = "الرجاء إدخال عدد الفراخ";
      chickenCostResult.value = "";
      feedCostResult.value = "";
      overheadCostResult.value = "";
      totalCostResult.value = "";
      salesResult.value = "";
      profitResult.value = "";
      update();
    }
  }

  void showStudyDetailsDialog() async {
    if (statusRequest != StatusRequest.success) {
      await fetchFeasibilityData();
    }

    if (statusRequest == StatusRequest.success) {
      DialogHelper.showDialog(
        middleText: "الأسعار المستخدمة في دراسة الجدوى \n"
            "سعر الكتكوت : $chickPrice ج\n"
            "سعر بيع الفراخ : $chickenSalePrice ج\n"
            "سعر علف بادي : $badiPrice ج\n"
            "سعر علف نامي : $namiPrice ج\n"
            "سعر علف ناهي : $nahiPrice ج\n\n"
            "طريقة حساب دراسة الجدوى\n\n"
            "تكلفة الكتاكيت = عدد الكتاكيت × سعر الكتكوت\n\n"
            "تكلفة العلف = استهلاك العلف البادي × سعر علف بادي +\n"
            "استهلاك العلف النامي × سعر علف نامي +\n"
            "استهلاك العلف الناهي × سعر علف ناهي\n\n"
            "النثريات = عدد الفراخ × 10ج لكل فرخة\n\n"
            "إجمالي التكاليف = تكلفة الكتاكيت + تكلفة العلف + النثريات\n\n"
            "إجمالي المبيعات = عدد الفراخ × سعر بيع الفراخ\n\n"
            "الربح النهائي = إجمالي المبيعات - إجمالي التكاليف",
      );
    } else {
      DialogHelper.showDialog(
        middleText: "عذرًا، تعذر تحميل البيانات. حاول مرة أخرى لاحقًا.",
      );
    }
  }

  void showFeasibilityGuide() {
    DialogHelper.showDialog(
        middleText:
            "تم إعداد هذه المعلومات لتقديم إرشادات عامة فقط، ولا يُقصد منها أن تكون بديلاً عن المشورة المتخصصة. يُرجى التحقق من التفاصيل والتأكد من مطابقتها لاحتياجاتك الخاصة قبل اتخاذ أي قرارات بناءً عليها.");
  }

  void checkAndShowDialog() {
    if (myServices.getStorage.read("feasibilityStudyDialog") != false) {
      showFeasibilityGuide();
      myServices.getStorage.write("feasibilityStudyDialog", false);
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
