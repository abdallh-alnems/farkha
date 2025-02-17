import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/data_source/static/growth_parameters.dart';

class FeedConsumptionController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final Rxn selectedAge = Rxn<int>();
  final RxString result = 'ادخل العدد والعمر'.obs;
  final RxBool isCumulative = false.obs;

  FeedConsumptionController() {
    textController.addListener(() {
      if (_areInputsValid()) {
        calculateFeedConsumption();
      }
    });
  }

  bool _areInputsValid() {
    if (isCumulative.value) {
      return textController.text.isNotEmpty &&
          int.tryParse(textController.text) != null;
    }
    return textController.text.isNotEmpty &&
        int.tryParse(textController.text) != null &&
        selectedAge.value != null;
  }

  void calculateFeedConsumption() {
    final int? count = int.tryParse(textController.text);

    if (count == null) {
      result.value = 'الرجاء إدخال عدد صحيح';
      return;
    }

    double totalFeed;

    if (isCumulative.value) {
      double badi = count * 0.5;
      double nami = count * 1.2;
      double nahi = count * 1.8;
      double total = count * 3.5;
      result.value =
          'استهلاك ${textController.text} فرخ للعلف طوال الدورة :\n \n'
          'استهلاك العلف البادي : ${badi.toStringAsFixed(0)} كيلو\n \n'
          'استهلاك العلف النامي : ${nami.toStringAsFixed(0)} كيلو\n \n'
          'استهلاك العلف الناهي : ${nahi.toStringAsFixed(0)} كيلو\n \n'
          'الاستهلاك الكلي للعلف طوال الدورة : ${total.toStringAsFixed(0)} كيلو';
    } else {
      if (selectedAge.value == null) {
        result.value = 'الرجاء تحديد العمر';
        return;
      }

      totalFeed = feedConsumptions[selectedAge.value! - 1] * count.toDouble();

      if (totalFeed < 1000) {
        result.value =
            'استهلاك ${textController.text} فراخ للعلف في اليوم عند عمر ${selectedAge.value} يوم : \n${totalFeed.toStringAsFixed(0)} جرام';
      } else {
        double totalFeedInKilo = totalFeed / 1000;
        result.value =
            'استهلاك ${textController.text} فراخ للعلف في اليوم عند عمر ${selectedAge.value} يوم : \n${totalFeedInKilo.toStringAsFixed(1)} كيلو';
      }
    }
  }

  void _resetResultMessage() {
    if (textController.text.isEmpty) {
      if (isCumulative.value) {
        result.value = 'ادخل العدد';
      } else {
        result.value = 'ادخل العدد والعمر';
      }
    }
  }

  void resetInputs() {
    isCumulative.value = !isCumulative.value;
    selectedAge.value ??= 1;
    calculateFeedConsumption();
    _resetResultMessage();
    FocusScope.of(Get.context!).unfocus();
  }
}
