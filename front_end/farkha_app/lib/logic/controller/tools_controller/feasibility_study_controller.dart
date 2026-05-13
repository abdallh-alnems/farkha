import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/class/status_request.dart';
import '../../../core/functions/handling_data_controller.dart';
import '../../../core/functions/number_format.dart';
import '../../../data/data_source/remote/tools/feasibility_study_data.dart';
import '../../../data/model/feasibility_model.dart';
import 'feasibility_calculations.dart';

class FeasibilityController extends GetxController {
  late StatusRequest statusRequest = StatusRequest.none;
  Rx<StatusRequest> pricesStatusRequest = StatusRequest.none.obs;
  final TextEditingController countController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  final TextEditingController defaultWeightController = TextEditingController();
  final TextEditingController badiRatioController = TextEditingController();
  final TextEditingController namiRatioController = TextEditingController();
  final TextEditingController nahiRatioController = TextEditingController();
  final TextEditingController averageFeedRatioController =
      TextEditingController();
  final TextEditingController mortalityRateController = TextEditingController();
  final TextEditingController overheadController = TextEditingController();

  final TextEditingController chickPriceController = TextEditingController();
  final TextEditingController badiPriceController = TextEditingController();
  final TextEditingController namiPriceController = TextEditingController();
  final TextEditingController nahiPriceController = TextEditingController();
  final TextEditingController averageFeedPriceController =
      TextEditingController();

  final FeasibilityData _feasibilityDataService = FeasibilityData(Get.find());
  late FeasibilityModel feasibilityModel;

  RxBool isChickenCountMode = true.obs;
  RxBool isProfessionalMode = false.obs;

  RxString mortalityRateText = ''.obs;
  RxString chickenCostText = ''.obs;
  RxString feedCostText = ''.obs;
  RxString overheadCostText = ''.obs;
  RxString totalCostText = ''.obs;
  RxString chickenCountText = ''.obs;
  RxString costPerChickenText = ''.obs;
  RxString costPerKgText = ''.obs;
  RxString totalKgProducedText = ''.obs;

  RxDouble totalChickenCostRaw = 0.0.obs;
  RxDouble totalFeedCostRaw = 0.0.obs;
  RxDouble totalOverheadCostRaw = 0.0.obs;

  RxBool showResults = false.obs;
  RxBool showInputs = true.obs;

  RxDouble defaultWeight = 2.1.obs;
  RxDouble badiFeedRatio = 0.5.obs;
  RxDouble namiFeedRatio = 1.2.obs;
  RxDouble nahiFeedRatio = 1.8.obs;
  RxDouble mortalityRate = 5.0.obs;
  RxDouble overheadPerChicken = 10.0.obs;

  FeasibilityDisplayTexts? _currentTexts;

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
    chickPriceController.text = feasibilityModel.chickPrice.toString();
    badiPriceController.text = feasibilityModel.badiPrice.toString();
    namiPriceController.text = feasibilityModel.namiPrice.toString();
    nahiPriceController.text = feasibilityModel.nahiPrice.toString();

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
    feasibilityModel.chickPrice =
        tryParseInt(chickPriceController.text) ?? 0;

    if (isProfessionalMode.value) {
      feasibilityModel.badiPrice =
          tryParseInt(badiPriceController.text) ?? 0;
      feasibilityModel.namiPrice =
          tryParseInt(namiPriceController.text) ?? 0;
      feasibilityModel.nahiPrice =
          tryParseInt(nahiPriceController.text) ?? 0;
    } else {
      final avgPrice = tryParseInt(averageFeedPriceController.text) ?? 0;
      feasibilityModel.badiPrice = avgPrice;
      feasibilityModel.namiPrice = avgPrice;
      feasibilityModel.nahiPrice = avgPrice;
    }
  }

  void updateDefaultValues() {
    defaultWeight.value =
        tryParseNum(defaultWeightController.text) ?? 2.1;
    mortalityRate.value =
        tryParseNum(mortalityRateController.text) ?? 5.0;
    overheadPerChicken.value =
        tryParseNum(overheadController.text) ?? 10.0;

    if (isProfessionalMode.value) {
      badiFeedRatio.value =
          tryParseNum(badiRatioController.text) ?? 0.5;
      namiFeedRatio.value =
          tryParseNum(namiRatioController.text) ?? 1.2;
      nahiFeedRatio.value =
          tryParseNum(nahiRatioController.text) ?? 1.8;
    } else {
      final avgRatio =
          tryParseNum(averageFeedRatioController.text) ?? 3.5;
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
    chickenCountText.value = '';
    costPerChickenText.value = '';
    costPerKgText.value = '';
    totalKgProducedText.value = '';
    totalChickenCostRaw.value = 0.0;
    totalFeedCostRaw.value = 0.0;
    totalOverheadCostRaw.value = 0.0;
    _currentTexts = null;
  }

  void toggleInputsVisibility() {
    showInputs.value = !showInputs.value;
    if (showInputs.value) {
      showResults.value = false;
    }
  }

  FeasibilityInput _buildInput(int chickenCount) {
    return FeasibilityInput(
      chickenCount: chickenCount,
      model: feasibilityModel,
      mortalityRate: mortalityRate.value,
      overheadPerChicken: overheadPerChicken.value,
      defaultWeight: defaultWeight.value,
      isProfessionalMode: isProfessionalMode.value,
      badiFeedRatio: badiFeedRatio.value,
      namiFeedRatio: namiFeedRatio.value,
      nahiFeedRatio: nahiFeedRatio.value,
      averageFeedRatio:
          tryParseNum(averageFeedRatioController.text) ?? 3.5,
      averageFeedPrice:
          (tryParseInt(averageFeedPriceController.text) ?? 0).toDouble(),
    );
  }

  Future<void> calculateFeasibility() async {
    showResults.value = true;
    showInputs.value = false;

    try {
      if (statusRequest != StatusRequest.success) {
        feasibilityModel = FeasibilityModel(
          chickPrice: 0,
          badiPrice: 0,
          namiPrice: 0,
          nahiPrice: 0,
        );
      }

      updatePrices();
      updateDefaultValues();

      int chickenCount;
      if (isChickenCountMode.value) {
        chickenCount = int.parse(countController.text);
      } else {
        final budget = double.parse(budgetController.text);
        chickenCount =
            calculateChickenCountFromBudget(budget, _buildInput(1));
      }

      final result = computeFeasibility(_buildInput(chickenCount));
      final texts = formatResultTexts(
        result,
        isChickenCountMode.value,
        defaultWeight.value,
      );
      _currentTexts = texts;
      _applyDisplayTexts(texts);

      update();
    } catch (e) {
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

  void _applyDisplayTexts(FeasibilityDisplayTexts texts) {
    totalChickenCostRaw.value = texts.totalChickenCostRaw;
    totalFeedCostRaw.value = texts.totalFeedCostRaw;
    totalOverheadCostRaw.value = texts.totalOverheadCostRaw;
    chickenCountText.value = texts.chickenCountText;
    mortalityRateText.value = texts.mortalityRateText;
    chickenCostText.value = texts.chickenCostText;
    feedCostText.value = texts.feedCostText;
    overheadCostText.value = texts.overheadCostText;
    totalCostText.value = texts.totalCostText;
    costPerChickenText.value = texts.costPerChickenText;
    costPerKgText.value = texts.costPerKgText;
    totalKgProducedText.value = texts.totalKgProducedText;
  }

  Future<void> shareAsText() async {
    if (_currentTexts == null) return;
    final text = buildShareText(_currentTexts!);
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'دراسة جدوى - تطبيق فَرْخة'),
    );
  }

  Future<void> shareAsPdf() async {
    if (_currentTexts == null) return;
    final pdf = await buildFeasibilityPdf(_currentTexts!);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/feasibility_study.pdf');
    await file.writeAsBytes(await pdf.save());
    await SharePlus.instance.share(
      ShareParams(
          files: [XFile(file.path)], subject: 'دراسة جدوى - تطبيق فَرْخة'),
    );
  }

  Future<void> shareAsExcel() async {
    if (_currentTexts == null) return;
    final bytes = buildFeasibilityExcel(_currentTexts!);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/feasibility_study.xlsx');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(
          files: [XFile(file.path)], subject: 'دراسة جدوى - تطبيق فَرْخة'),
    );
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
    chickPriceController.dispose();
    badiPriceController.dispose();
    namiPriceController.dispose();
    nahiPriceController.dispose();
    averageFeedPriceController.dispose();
    super.onClose();
  }
}
