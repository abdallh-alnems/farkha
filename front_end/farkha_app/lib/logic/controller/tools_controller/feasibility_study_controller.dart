import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/functions/handling_data_controller.dart';
import '../../../data/data_source/remote/tools/feasibility_study_data.dart';
import '../../../data/model/feasibility_model.dart';

class FeasibilityController extends GetxController {
  late StatusRequest statusRequest = StatusRequest.none;
  Rx<StatusRequest> pricesStatusRequest = StatusRequest.none.obs;
  final TextEditingController countController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  // Controllers for default values
  final TextEditingController defaultWeightController = TextEditingController();
  final TextEditingController badiRatioController = TextEditingController();
  final TextEditingController namiRatioController = TextEditingController();
  final TextEditingController nahiRatioController = TextEditingController();
  final TextEditingController averageFeedRatioController =
      TextEditingController(); // للوضع الاحترافي
  final TextEditingController mortalityRateController = TextEditingController();
  final TextEditingController overheadController = TextEditingController();

  // Controllers for price inputs
  final TextEditingController chickenSalePriceController =
      TextEditingController();
  final TextEditingController chickPriceController = TextEditingController();
  final TextEditingController badiPriceController = TextEditingController();
  final TextEditingController namiPriceController = TextEditingController();
  final TextEditingController nahiPriceController = TextEditingController();
  final TextEditingController averageFeedPriceController =
      TextEditingController(); // للوضع الاحترافي

  final FeasibilityData _feasibilityDataService = FeasibilityData(Get.find());
  late FeasibilityModel feasibilityModel;

  // Calculation type
  RxBool isChickenCountMode =
      true.obs; // true for chicken count, false for budget

  // Professional mode toggle
  RxBool isProfessionalMode =
      false.obs; // true for professional, false for normal

  RxString mortalityRateText = ''.obs;
  RxString chickenCostText = ''.obs;
  RxString feedCostText = ''.obs;
  RxString overheadCostText = ''.obs;
  RxString totalCostText = ''.obs;
  RxString totalSalesText = ''.obs;
  RxString profitText = ''.obs;
  RxString chickenCountText = ''.obs; // For budget mode
  RxString costPerChickenText = ''.obs;
  RxString profitPerChickenText = ''.obs;
  RxString profitMarginText = ''.obs;
  RxString costPerKgText = ''.obs;
  RxString totalKgProducedText = ''.obs;
  RxBool isProfitNegative = false.obs;

  // Raw cost values for chart
  RxDouble totalChickenCostRaw = 0.0.obs;
  RxDouble totalFeedCostRaw = 0.0.obs;
  RxDouble totalOverheadCostRaw = 0.0.obs;

  RxBool showResults = false.obs;
  RxBool showInputs = true.obs; // إظهار المدخلات، false لإخفائها عند الحساب

  // Reactive variables for customizable values
  RxDouble defaultWeight = 2.1.obs;
  RxDouble badiFeedRatio = 0.5.obs;
  RxDouble namiFeedRatio = 1.2.obs;
  RxDouble nahiFeedRatio = 1.8.obs;
  RxDouble mortalityRate = 5.0.obs; // 5% default mortality rate
  RxDouble overheadPerChicken = 10.0.obs; // 10 ج per chicken default

  Future<void> fetchFeasibilityData() async {
    try {
      pricesStatusRequest.value = StatusRequest.loading;

      final response = await _feasibilityDataService.getData();
      pricesStatusRequest.value = handlingData(response);

      if (pricesStatusRequest.value == StatusRequest.success) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == 'success') {
          feasibilityModel = FeasibilityModel.fromJson(
            mapResponse['data'] as List<dynamic>,
          );
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

    // حساب متوسط سعر العلف للوضع الاحترافي
    final averageFeedPrice =
        ((feasibilityModel.badiPrice +
                    feasibilityModel.namiPrice +
                    feasibilityModel.nahiPrice) /
                3)
            .round();
    averageFeedPriceController.text = averageFeedPrice.toString();
  }

  void resetPricesStatus() {
    pricesStatusRequest.value = StatusRequest.none;
  }

  void updatePrices() {
    feasibilityModel.chickenSalePrice =
        int.tryParse(chickenSalePriceController.text) ?? 0;
    feasibilityModel.chickPrice = int.tryParse(chickPriceController.text) ?? 0;

    if (isProfessionalMode.value) {
      // في الوضع الاحترافي، استخدم أسعار العلف المنفصلة
      feasibilityModel.badiPrice = int.tryParse(badiPriceController.text) ?? 0;
      feasibilityModel.namiPrice = int.tryParse(namiPriceController.text) ?? 0;
      feasibilityModel.nahiPrice = int.tryParse(nahiPriceController.text) ?? 0;
    } else {
      // في الوضع العادي، استخدم متوسط السعر لجميع أنواع العلف
      final avgPrice = int.tryParse(averageFeedPriceController.text) ?? 0;
      feasibilityModel.badiPrice = avgPrice;
      feasibilityModel.namiPrice = avgPrice;
      feasibilityModel.nahiPrice = avgPrice;
    }
  }

  void updateDefaultValues() {
    // استخدم القيم من الحقول، وإذا كانت فارغة استخدم القيم الافتراضية
    defaultWeight.value = double.tryParse(defaultWeightController.text) ?? 2.1;
    mortalityRate.value = double.tryParse(mortalityRateController.text) ?? 5.0;
    overheadPerChicken.value = double.tryParse(overheadController.text) ?? 10.0;

    if (isProfessionalMode.value) {
      // في الوضع الاحترافي، استخدم النسب المنفصلة
      badiFeedRatio.value = double.tryParse(badiRatioController.text) ?? 0.5;
      namiFeedRatio.value = double.tryParse(namiRatioController.text) ?? 1.2;
      nahiFeedRatio.value = double.tryParse(nahiRatioController.text) ?? 1.8;
    } else {
      // في الوضع العادي، استخدم متوسط نسبة العلف لجميع الأنواع
      final avgRatio = double.tryParse(averageFeedRatioController.text) ?? 3.5;
      badiFeedRatio.value = avgRatio;
      namiFeedRatio.value = avgRatio;
      nahiFeedRatio.value = avgRatio;
    }
  }

  void toggleCalculationMode() {
    isChickenCountMode.value = !isChickenCountMode.value;
    showResults.value = false;
    _clearResultTexts();
  }

  void toggleProfessionalMode() {
    isProfessionalMode.value = !isProfessionalMode.value;
    showResults.value = false;
    _clearResultTexts();
  }

  void _clearResultTexts() {
    mortalityRateText.value = '';
    chickenCostText.value = '';
    feedCostText.value = '';
    overheadCostText.value = '';
    totalCostText.value = '';
    totalSalesText.value = '';
    profitText.value = '';
    chickenCountText.value = '';
    costPerChickenText.value = '';
    profitPerChickenText.value = '';
    profitMarginText.value = '';
    costPerKgText.value = '';
    totalKgProducedText.value = '';
    isProfitNegative.value = false;
    totalChickenCostRaw.value = 0.0;
    totalFeedCostRaw.value = 0.0;
    totalOverheadCostRaw.value = 0.0;
  }

  void toggleInputsVisibility() {
    showInputs.value = !showInputs.value;
    if (showInputs.value) {
      showResults.value = false; // إخفاء النتائج عند إظهار المدخلات
    }
  }

  Future<void> calculateFeasibility() async {
    showResults.value = true;
    showInputs.value = false; // إخفاء المدخلات عند الحساب

    try {
      // تهيئة feasibilityModel بقيم افتراضية إذا لم تكن موجودة
      if (statusRequest != StatusRequest.success) {
        feasibilityModel = FeasibilityModel(
          chickenSalePrice: 0,
          chickPrice: 0,
          badiPrice: 0,
          namiPrice: 0,
          nahiPrice: 0,
        );
      }

      // Update prices and default values from controllers
      updatePrices();
      updateDefaultValues();

      int chickenCount;

      if (isChickenCountMode.value) {
        // Calculate based on chicken count
        chickenCount = int.parse(countController.text);
      } else {
        // Calculate based on budget
        final double budget = double.parse(budgetController.text);
        chickenCount = _calculateChickenCountFromBudget(budget);
      }

      int deadChickens = (chickenCount * mortalityRate.value / 100).round();
      if (deadChickens > chickenCount) deadChickens = chickenCount;
      final int remainingChickens = chickenCount - deadChickens;

      final int totalChickenCost = chickenCount * feasibilityModel.chickPrice;
      final double feedCostForAll = _calculateFeedCost(chickenCount);
      final double feedCostPerChicken = _calculateFeedCost(1);
      final double feedDeductionForDead =
          deadChickens * 0.5 * feedCostPerChicken;
      final double totalFeedCost = feedCostForAll - feedDeductionForDead;
      final double totalOverheadCost = chickenCount * overheadPerChicken.value;
      final double totalCost =
          totalChickenCost + totalFeedCost + totalOverheadCost;

      final int totalSales =
          (remainingChickens *
                  defaultWeight.value *
                  feasibilityModel.chickenSalePrice)
              .round();
      final double profit = totalSales - totalCost;

      final int deadChickenChickCost =
          chickenCount > 0
              ? (deadChickens * totalChickenCost / chickenCount).round()
              : 0;
      final double deadChickenFeedCost =
          deadChickens * 0.5 * feedCostPerChicken;
      final double deadChickenOverheadCost =
          deadChickens * overheadPerChicken.value;
      final int deadChickenTotalCost =
          (deadChickenChickCost + deadChickenFeedCost + deadChickenOverheadCost)
              .round();

      _updateResultText(
        chickenCount,
        deadChickens,
        deadChickenTotalCost,
        totalChickenCost,
        totalFeedCost,
        totalOverheadCost,
        totalCost,
        totalSales,
        profit,
      );

      update();
    } catch (e, stackTrace) {
      debugPrint('Feasibility calculation error: $e\n$stackTrace');
      statusRequest = StatusRequest.failure;
      update();
      Get.snackbar(
        'خطأ في الحساب',
        'حدث خطأ أثناء الحساب. تأكد من صحة المدخلات وحاول مرة أخرى',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  int _calculateChickenCountFromBudget(double budget) {
    // Calculate how many chickens can be bought with the given budget
    // We need to estimate the total cost per chicken
    final double costPerChicken = feasibilityModel.chickPrice.toDouble();
    final double feedCostPerChicken = _calculateFeedCost(
      1,
    ); // Cost for 1 chicken
    final double overheadCostPerChicken = overheadPerChicken.value;

    final double totalCostPerChicken =
        costPerChicken + feedCostPerChicken + overheadCostPerChicken;

    return (budget / totalCostPerChicken).floor();
  }

  double _calculateFeedCost(int chickenCount) {
    if (isProfessionalMode.value) {
      // في الوضع الاحترافي، استخدم النسب المنفصلة
      final double badiFeedCost =
          badiFeedRatio.value * (feasibilityModel.badiPrice / 1000);
      final double namiFeedCost =
          namiFeedRatio.value * (feasibilityModel.namiPrice / 1000);
      final double nahiFeedCost =
          nahiFeedRatio.value * (feasibilityModel.nahiPrice / 1000);

      return (badiFeedCost + namiFeedCost + nahiFeedCost) * chickenCount;
    } else {
      // في الوضع العادي، استخدم متوسط نسبة العلف مرة واحدة
      final double avgFeedRatio =
          double.tryParse(averageFeedRatioController.text) ?? 3.5;
      final double avgFeedPrice =
          (int.tryParse(averageFeedPriceController.text) ?? 0).toDouble();

      return avgFeedRatio * (avgFeedPrice / 1000) * chickenCount;
    }
  }

  static String _formatNoTrailingZero(double value, int decimals) {
    final s = value.toStringAsFixed(decimals);
    return s.replaceAll(RegExp(r'\.0+$'), '');
  }

  void _updateResultText(
    int chickenCount,
    int deadChickens,
    int deadChickenTotalCost,
    int totalChickenCost,
    double totalFeedCost,
    double totalOverheadCost,
    double totalCost,
    int totalSales,
    double profit,
  ) {
    totalChickenCostRaw.value = totalChickenCost.toDouble();
    totalFeedCostRaw.value = totalFeedCost;
    totalOverheadCostRaw.value = totalOverheadCost;

    if (isChickenCountMode.value) {
      chickenCountText.value = '';
    } else {
      chickenCountText.value = '$chickenCount فرخ';
    }

    mortalityRateText.value =
        deadChickenTotalCost > 0
            ? '$deadChickens فرخ ($deadChickenTotalCost ج)'
            : '$deadChickens فرخ';
    chickenCostText.value = '$totalChickenCost ج';
    feedCostText.value = '${totalFeedCost.toStringAsFixed(0)} ج';
    overheadCostText.value = '${totalOverheadCost.toStringAsFixed(0)} ج';
    totalCostText.value = '${totalCost.toStringAsFixed(0)} ج';
    totalSalesText.value = '${totalSales.toStringAsFixed(0)} ج';
    profitText.value = '${profit.toStringAsFixed(0)} ج';
    isProfitNegative.value = profit < 0;

    final int remainingChickens = chickenCount - deadChickens;
    if (remainingChickens > 0) {
      final double costPerChicken = totalCost / remainingChickens;
      costPerChickenText.value = '${costPerChicken.toStringAsFixed(0)} ج';

      final double profitPerChicken = profit / remainingChickens;
      profitPerChickenText.value = '${profitPerChicken.toStringAsFixed(0)} ج';

      final double totalKg = remainingChickens * defaultWeight.value;
      if (totalKg > 0) {
        final double tons = totalKg / 1000;
        totalKgProducedText.value =
            totalKg >= 1000
                ? '${_formatNoTrailingZero(tons, 1)} طن'
                : '${_formatNoTrailingZero(totalKg, 1)} كجم';
        final double costPerKg = totalCost / totalKg;
        costPerKgText.value = '${_formatNoTrailingZero(costPerKg, 1)} ج/كجم';
      } else {
        totalKgProducedText.value = '-';
        costPerKgText.value = '-';
      }
      if (totalSales > 0) {
        final double margin = (profit / totalSales) * 100;
        profitMarginText.value = '${_formatNoTrailingZero(margin, 1)}%';
      } else {
        profitMarginText.value = '-';
      }
    } else {
      costPerChickenText.value = '-';
      profitPerChickenText.value = '-';
      profitMarginText.value = '-';
      costPerKgText.value = '-';
      totalKgProducedText.value = '-';
    }
  }

  String buildShareText() {
    final buffer = StringBuffer();
    buffer.writeln('تطبيق فَرْخة');
    buffer.writeln('دراسة جدوى');
    buffer.writeln();
    if (chickenCountText.value.isNotEmpty) {
      buffer.writeln('عدد الفراخ: ${chickenCountText.value}');
      buffer.writeln();
    }
    buffer.writeln('التكاليف:');
    buffer.writeln('• النافق: ${mortalityRateText.value}');
    buffer.writeln('• سعر الكتاكيت: ${chickenCostText.value}');
    buffer.writeln('• تكلفة العلف: ${feedCostText.value}');
    buffer.writeln('• النثريات: ${overheadCostText.value}');
    buffer.writeln('• التكلفة الإجمالية: ${totalCostText.value}');
    if (costPerChickenText.value.isNotEmpty &&
        costPerChickenText.value != '-') {
      buffer.writeln('• تكلفة الفرخ الواحد: ${costPerChickenText.value}');
    }
    if (costPerKgText.value.isNotEmpty && costPerKgText.value != '-') {
      buffer.writeln('• تكلفة الكيلو: ${costPerKgText.value}');
    }
    buffer.writeln();
    buffer.writeln('المبيعات:');
    if (totalKgProducedText.value.isNotEmpty &&
        totalKgProducedText.value != '-') {
      buffer.writeln('• الكيلوجرامات المنتجة: ${totalKgProducedText.value}');
    }
    buffer.writeln('• إجمالي المبيعات: ${totalSalesText.value}');
    buffer.writeln();
    buffer.writeln('الأرباح:');
    final profitDisplay =
        profitMarginText.value.isNotEmpty && profitMarginText.value != '-'
            ? '${profitText.value} (${profitMarginText.value})'
            : profitText.value;
    buffer.writeln('• صافي الأرباح: $profitDisplay');
    if (profitPerChickenText.value.isNotEmpty &&
        profitPerChickenText.value != '-') {
      buffer.writeln('• الربح لكل فرخ: ${profitPerChickenText.value}');
    }
    return buffer.toString();
  }

  Future<void> ensureFeasibilityData() async {
    if (statusRequest != StatusRequest.success) {
      await fetchFeasibilityData();
    }
  }

  @override
  void onInit() {
    super.onInit();
    pricesStatusRequest.value = StatusRequest.none;

    // Initialize default values in text controllers - leave empty initially
    // Values will be loaded when user clicks "القيم الافتراضية" button
    defaultWeightController.clear();
    badiRatioController.clear();
    namiRatioController.clear();
    nahiRatioController.clear();
    mortalityRateController.clear();
    overheadController.clear();
  }

  @override
  void onClose() {
    countController.dispose();
    budgetController.dispose();
    defaultWeightController.dispose();
    badiRatioController.dispose();
    namiRatioController.dispose();
    nahiRatioController.dispose();
    averageFeedRatioController.dispose();
    mortalityRateController.dispose();
    overheadController.dispose();
    chickenSalePriceController.dispose();
    chickPriceController.dispose();
    badiPriceController.dispose();
    namiPriceController.dispose();
    nahiPriceController.dispose();
    averageFeedPriceController.dispose();
    super.onClose();
  }
}
