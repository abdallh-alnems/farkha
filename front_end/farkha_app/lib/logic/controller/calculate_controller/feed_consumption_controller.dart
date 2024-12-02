import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/data_source/static/poultry_management_data.dart';

class FeedConsumptionController extends GetxController {
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  final TextEditingController countController = TextEditingController();
  final Rxn selectedAge = Rxn<int>();
  final RxString result = 'ادخل العدد والعمر'.obs;
  final RxBool isCumulative = false.obs;
  final List<int> feedConsumption = feedConsumptions;

  FeedConsumptionController() {
    countController.addListener(() {
      if (_areInputsValid()) {
        calculateFeedConsumption();
      }
    });
  }

  bool _areInputsValid() {
    if (isCumulative.value) {
      return countController.text.isNotEmpty;
    }
    return countController.text.isNotEmpty && selectedAge.value != null;
  }

  void calculateFeedConsumption() {
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
      totalFeed = feedConsumption[selectedAge.value! - 1] * count.toDouble();
      result.value =
          'استهلاك ${countController.text} فراخ للعلف في اليوم عند عمر ${selectedAge.value} يوم : \n${totalFeed.toStringAsFixed(0)} جرام';
    }
    FocusScope.of(Get.context!).unfocus();
  }

  void _resetResultMessage() {
    if (countController.text.isEmpty) {
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
  }
}
