import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/tool_ids.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../core/package/dialogs/usage_tips_dialog.dart';
import '../../../data/data_source/remote/feasibility_study_data.dart';
import '../../../data/model/feasibility_model.dart';
import '../tool_usage_controller.dart';

class FeasibilityController extends GetxController {
  static const int toolId =
      ToolIds.feasibilityStudy; // Feasibility Study tool ID = 14

  late StatusRequest statusRequest = StatusRequest.none;
  Rx<StatusRequest> pricesStatusRequest = StatusRequest.none.obs;
  final TextEditingController countController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  // Controllers for default values
  final TextEditingController defaultWeightController = TextEditingController();
  final TextEditingController badiRatioController = TextEditingController();
  final TextEditingController namiRatioController = TextEditingController();
  final TextEditingController nahiRatioController = TextEditingController();
  final TextEditingController mortalityRateController = TextEditingController();
  final TextEditingController overheadController = TextEditingController();

  // Controllers for price inputs
  final TextEditingController chickenSalePriceController =
      TextEditingController();
  final TextEditingController chickPriceController = TextEditingController();
  final TextEditingController badiPriceController = TextEditingController();
  final TextEditingController namiPriceController = TextEditingController();
  final TextEditingController nahiPriceController = TextEditingController();

  final FeasibilityData _feasibilityDataService = FeasibilityData(Get.find());
  late FeasibilityModel feasibilityModel;

  // Calculation type
  RxBool isChickenCountMode =
      true.obs; // true for chicken count, false for budget

  RxString mortalityRateText = "".obs;
  RxString chickenCostText = "".obs;
  RxString feedCostText = "".obs;
  RxString overheadCostText = "".obs;
  RxString totalCostText = "".obs;
  RxString totalSalesText = "".obs;
  RxString profitText = "".obs;
  RxString chickenCountText = "".obs; // For budget mode

  RxBool showResults = false.obs;
  RxBool isPricesExpanded = true.obs;

  // Reactive variables for customizable values
  RxDouble defaultWeight = 2.5.obs;
  RxDouble badiFeedRatio = 0.5.obs;
  RxDouble namiFeedRatio = 1.2.obs;
  RxDouble nahiFeedRatio = 1.8.obs;
  RxDouble mortalityRate = 5.0.obs; // 5% default mortality rate
  RxDouble overheadPerChicken = 10.0.obs; // 10 ج per chicken default

  Future<void> fetchFeasibilityData() async {
    try {
      pricesStatusRequest.value = StatusRequest.loading;

      var response = await _feasibilityDataService.getData();
      pricesStatusRequest.value = handlingData(response);

      if (pricesStatusRequest.value == StatusRequest.success) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == "success") {
          feasibilityModel = FeasibilityModel.fromJson(mapResponse['data']);
          _updatePriceControllers();
        } else {
          pricesStatusRequest.value = StatusRequest.failure;
        }
      }
    } catch (e) {
      pricesStatusRequest.value = StatusRequest.failure;
    }
  }

  void _updatePriceControllers() {
    chickenSalePriceController.text =
        feasibilityModel.chickenSalePrice.toString();
    chickPriceController.text = feasibilityModel.chickPrice.toString();
    badiPriceController.text = feasibilityModel.badiPrice.toString();
    namiPriceController.text = feasibilityModel.namiPrice.toString();
    nahiPriceController.text = feasibilityModel.nahiPrice.toString();
  }

  void resetPricesStatus() {
    pricesStatusRequest.value = StatusRequest.none;
  }

  void updatePrices() {
    feasibilityModel.chickenSalePrice =
        int.tryParse(chickenSalePriceController.text) ?? 0;
    feasibilityModel.chickPrice = int.tryParse(chickPriceController.text) ?? 0;
    feasibilityModel.badiPrice = int.tryParse(badiPriceController.text) ?? 0;
    feasibilityModel.namiPrice = int.tryParse(namiPriceController.text) ?? 0;
    feasibilityModel.nahiPrice = int.tryParse(nahiPriceController.text) ?? 0;
  }

  void updateDefaultValues() {
    defaultWeight.value = double.tryParse(defaultWeightController.text) ?? 2.5;
    badiFeedRatio.value = double.tryParse(badiRatioController.text) ?? 0.5;
    namiFeedRatio.value = double.tryParse(namiRatioController.text) ?? 1.2;
    nahiFeedRatio.value = double.tryParse(nahiRatioController.text) ?? 1.8;
    mortalityRate.value = double.tryParse(mortalityRateController.text) ?? 5.0;
    overheadPerChicken.value = double.tryParse(overheadController.text) ?? 10.0;
  }

  void toggleCalculationMode() {
    isChickenCountMode.value = !isChickenCountMode.value;
    showResults.value = false;
    // Clear previous results
    mortalityRateText.value = "";
    chickenCostText.value = "";
    feedCostText.value = "";
    overheadCostText.value = "";
    totalCostText.value = "";
    totalSalesText.value = "";
    profitText.value = "";
    chickenCountText.value = "";
  }

  void calculateFeasibility() async {
    print("Starting calculation...");
    showResults.value = true;

    try {
      if (statusRequest != StatusRequest.success) {
        print("Fetching data from API...");
        await fetchFeasibilityData();
      }

      // Update prices and default values from controllers
      updatePrices();
      updateDefaultValues();
      print(
        "Prices updated: ${feasibilityModel.chickenSalePrice}, ${feasibilityModel.chickPrice}",
      );

      int chickenCount;

      if (isChickenCountMode.value) {
        // Calculate based on chicken count
        chickenCount = int.parse(countController.text);
        print("Chicken count mode: $chickenCount");
      } else {
        // Calculate based on budget
        double budget = double.parse(budgetController.text);
        chickenCount = _calculateChickenCountFromBudget(budget);
        print("Budget mode: $budget -> $chickenCount chickens");
      }

      int deadChickens = (chickenCount * mortalityRate.value / 100).round();
      // ضمان أن النافق لا يقل عن 1
      deadChickens = deadChickens < 1 ? 1 : deadChickens;
      int remainingChickens = chickenCount - deadChickens;

      int totalChickenCost = chickenCount * feasibilityModel.chickPrice;
      double totalFeedCost = _calculateFeedCost(chickenCount);
      double totalOverheadCost = chickenCount * overheadPerChicken.value;
      double totalCost = totalChickenCost + totalFeedCost + totalOverheadCost;

      int totalSales =
          (remainingChickens *
                  defaultWeight.value *
                  feasibilityModel.chickenSalePrice)
              .round();
      double profit = totalSales - totalCost;

      _updateResultText(
        chickenCount,
        deadChickens,
        totalChickenCost,
        totalFeedCost,
        totalOverheadCost,
        totalCost,
        totalSales,
        profit,
      );

      print("Results updated, calling update()");
      update();
    } catch (e) {
      print("Error in calculation: $e");
      statusRequest = StatusRequest.failure;
      update();
    }
  }

  int _calculateChickenCountFromBudget(double budget) {
    // Calculate how many chickens can be bought with the given budget
    // We need to estimate the total cost per chicken
    double costPerChicken = feasibilityModel.chickPrice.toDouble();
    double feedCostPerChicken = _calculateFeedCost(1); // Cost for 1 chicken
    double overheadCostPerChicken = overheadPerChicken.value;

    double totalCostPerChicken =
        costPerChicken + feedCostPerChicken + overheadCostPerChicken;

    return (budget / totalCostPerChicken).floor();
  }

  double _calculateFeedCost(int chickenCount) {
    double badiFeedCost =
        badiFeedRatio.value * (feasibilityModel.badiPrice / 1000);
    double namiFeedCost =
        namiFeedRatio.value * (feasibilityModel.namiPrice / 1000);
    double nahiFeedCost =
        nahiFeedRatio.value * (feasibilityModel.nahiPrice / 1000);

    return (badiFeedCost + namiFeedCost + nahiFeedCost) * chickenCount;
  }

  void _updateResultText(
    int chickenCount,
    int deadChickens,
    int totalChickenCost,
    double totalFeedCost,
    double totalOverheadCost,
    double totalCost,
    int totalSales,
    double profit,
  ) {
    if (isChickenCountMode.value) {
      // Chicken count mode
      chickenCountText.value = "";
    } else {
      // Budget mode
      chickenCountText.value = "$chickenCount فرخ";
    }

    mortalityRateText.value = "$deadChickens فرخ";
    chickenCostText.value = "$totalChickenCost ج";
    feedCostText.value = "${totalFeedCost.toStringAsFixed(0)} ج";
    overheadCostText.value = "${totalOverheadCost.toStringAsFixed(0)} ج";
    totalCostText.value = "${totalCost.toStringAsFixed(0)} ج";
    totalSalesText.value = "${totalSales.toStringAsFixed(0)} ج";
    profitText.value = "${profit.toStringAsFixed(0)} ج";
  }

  void ensureFeasibilityData() async {
    if (statusRequest != StatusRequest.success) {
      await fetchFeasibilityData();
    }
  }

  void showFeasibilityGuide() {
    UsageTipsDialog.showDialogIfNotShown('feasibilityStudyDialog');
  }

  @override
  void onInit() {
    super.onInit();
    ToolUsageController.recordToolUsageFromController(toolId);
    pricesStatusRequest.value = StatusRequest.none;
    isPricesExpanded.value = true; // إظهار حقول الأسعار عند الدخول

    // Initialize default values in text controllers - leave empty initially
    // Values will be loaded when user clicks "القيم الافتراضية" button
    defaultWeightController.clear();
    badiRatioController.clear();
    namiRatioController.clear();
    nahiRatioController.clear();
    mortalityRateController.clear();
    overheadController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showFeasibilityGuide();
    });
  }

  @override
  void onClose() {
    countController.dispose();
    budgetController.dispose();
    defaultWeightController.dispose();
    badiRatioController.dispose();
    namiRatioController.dispose();
    nahiRatioController.dispose();
    mortalityRateController.dispose();
    overheadController.dispose();
    chickenSalePriceController.dispose();
    chickPriceController.dispose();
    badiPriceController.dispose();
    namiPriceController.dispose();
    nahiPriceController.dispose();
    super.onClose();
  }
}
