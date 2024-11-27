import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/data_source/static/poultry_management_data.dart';

class FeedConsumptionController extends GetxController {
  final TextEditingController countController = TextEditingController();
  final Rxn selectedAge = Rxn<int>();
  final RxString result = ''.obs;
  final RxBool isCumulative = false.obs;

  final List<int> feedConsumption = feedConsumptions;

  void calculateFeedConsumption() {
    if (countController.text.isEmpty) {
      result.value = 'يرجى تعبئة جميع الحقول المطلوبة';
      return;
    }

    final int count = int.tryParse(countController.text) ?? 0;
    double totalFeed;

    if (isCumulative.value) {
      double badi = count * 0.5;
      double nami = count * 1.2;
      double nahi = count * 1.8;
      double total = count * 3.5;

      result.value =
          'استهلاك ${countController.text} فرخ للعلف طوال الدورة :\n \n'
          'استهلاك العلف البادي : ${badi.toStringAsFixed(1)} كيلو\n \n'
          'استهلاك العلف النامي : ${nami.toStringAsFixed(1)} كيلو\n \n'
          'استهلاك العلف الناهي : ${nahi.toStringAsFixed(1)} كيلو\n \n'
          'الاستهلاك الكلي للعلف طوال الدورة : ${total.toStringAsFixed(1)} كيلو';
    } else {
      if (selectedAge.value == null ||
          selectedAge.value! <= 0 ||
          selectedAge.value! > feedConsumption.length) {
        result.value = 'يرجى اختيار عمر صحيح ضمن المدى المحدد.';
        return;
      }

      totalFeed = feedConsumption[selectedAge.value! - 1] * count.toDouble();
      result.value =
          'استهلاك ${countController.text} فراخ للعلف في اليوم عند عمر ${selectedAge.value} يوم : \n${totalFeed.toStringAsFixed(0)} جرام';
    }
  }

  void resetInputs() {
    countController.clear();
    selectedAge.value = null;
    result.value = '';
  }
}
