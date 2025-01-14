import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../core/package/custom_dialog.dart';
import '../../../core/services/initialization.dart';
import '../../../data/data_source/remote/feasibility_study_data.dart';
import '../../../data/model/feasibility_model.dart';

class FeasibilityController extends GetxController {
  final MyServices _myServices = Get.find();
  late StatusRequest statusRequest = StatusRequest.none;
  final TextEditingController countController = TextEditingController();
  final FeasibilityData _feasibilityDataService = FeasibilityData(Get.find());
  late FeasibilityModel feasibilityModel;

  RxString mortalityRateText = "".obs;
  RxString chickenCostText = "".obs;
  RxString feedCostText = "".obs;
  RxString overheadCostText = "".obs;
  RxString totalCostText = "".obs;
  RxString totalSalesText = "".obs;
  RxString profitText = "".obs;

  RxBool showResults = false.obs;

  static const double mortalityRate = 0.05;
  static const double badiFeedConsumption = 0.5;
  static const double namiFeedConsumption = 1.2;
  static const double nahiFeedConsumption = 1.8;
  static const int overheadPerChicken = 10;
  static const int averageWeight = 2;

  Future<void> fetchFeasibilityData() async {
    try {
      statusRequest = StatusRequest.loading;
      update();

      var response = await _feasibilityDataService.getData();
      statusRequest = handlingData(response);

      if (statusRequest == StatusRequest.success &&
          response['status'] == "success") {
        feasibilityModel = FeasibilityModel.fromJson(response['data']);
      } else {
        statusRequest = StatusRequest.failure;
      }
      update();
    } catch (e) {
      statusRequest = StatusRequest.failure;
      update();
    }
  }

  void calculateFeasibility() async {
    showResults.value = true;

    try {
      if (statusRequest != StatusRequest.success) {
        await fetchFeasibilityData();
      }

      int chickenCount = int.parse(countController.text);

      int deadChickens = (chickenCount * mortalityRate).round();
      int remainingChickens = chickenCount - deadChickens;

      int totalChickenCost = chickenCount * feasibilityModel.chickPrice;
      double totalFeedCost = _calculateFeedCost(chickenCount);
      int totalOverheadCost = chickenCount * overheadPerChicken;
      double totalCost = totalChickenCost + totalFeedCost + totalOverheadCost;

      int totalSales =
          remainingChickens * averageWeight * feasibilityModel.chickenSalePrice;
      double profit = totalSales - totalCost;

      _updateResultText(deadChickens, totalChickenCost, totalFeedCost,
          totalOverheadCost, totalCost, totalSales, profit);

      update();
    } catch (e) {
      statusRequest = StatusRequest.failure;
      update();
    }
  }

  double _calculateFeedCost(int chickenCount) {
    double badiFeedCost =
        badiFeedConsumption * (feasibilityModel.badiPrice / 1000);
    double namiFeedCost =
        namiFeedConsumption * (feasibilityModel.namiPrice / 1000);
    double nahiFeedCost =
        nahiFeedConsumption * (feasibilityModel.nahiPrice / 1000);

    return (badiFeedCost + namiFeedCost + nahiFeedCost) * chickenCount;
  }

  void _updateResultText(
      int deadChickens,
      int totalChickenCost,
      double totalFeedCost,
      int totalOverheadCost,
      double totalCost,
      int totalSales,
      double profit) {
    mortalityRateText.value = "النافق : $deadChickens فراخ";
    chickenCostText.value = "سعر الكتاكيت : $totalChickenCost ج";
    feedCostText.value = "تكلفة العلف : ${totalFeedCost.toStringAsFixed(0)} ج";
    overheadCostText.value = "النثريات : $totalOverheadCost ج";
    totalCostText.value =
        "التكلفة الإجمالية: ${totalCost.toStringAsFixed(0)} ج";
    totalSalesText.value =
        "إجمالي المبيعات: ${totalSales.toStringAsFixed(0)} ج";
    profitText.value = "الأرباح: ${profit.toStringAsFixed(0)} ج";
  }

  void ensureFeasibilityData() async {
    if (statusRequest != StatusRequest.success) {
      await fetchFeasibilityData();
    }
  }

  void showFeasibilityGuide() {
    DialogHelper.showDialog(
        middleText:
            "تم إعداد هذه المعلومات لتقديم إرشادات عامة فقط، ولا يُقصد منها أن تكون بديلاً عن المشورة المتخصصة. يُرجى التحقق من التفاصيل والتأكد من مطابقتها لاحتياجاتك الخاصة قبل اتخاذ أي قرارات بناءً عليها.");
  }

  void checkAndShowDialog() {
    if (_myServices.getStorage.read("feasibilityStudyDialog") != false) {
      showFeasibilityGuide();
      _myServices.getStorage.write("feasibilityStudyDialog", false);
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
