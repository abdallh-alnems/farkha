import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/data_source/static/growth_parameters.dart';
import '../../../core/shared/bottom_message.dart';

class FeedConsumptionController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final Rxn selectedAge = Rxn<int>();
  final RxString result = ''.obs;
  final RxBool isCumulative = false.obs;

  bool _areInputsValid() {
    if (isCumulative.value) {
      return textController.text.isNotEmpty &&
          int.tryParse(textController.text) != null;
    }
    return textController.text.isNotEmpty &&
        int.tryParse(textController.text) != null &&
        selectedAge.value != null;
  }

  void calculateFeedConsumption(BuildContext context) {
    final int? count = int.tryParse(textController.text);

    if (count == null) {
      BottomMessage.show(context, 'الرجاء إدخال عدد صحيح');
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
        BottomMessage.show(context, 'الرجاء تحديد العمر');
        return;
      }

      totalFeed = feedConsumptions[selectedAge.value! - 1] * count.toDouble();

      if (totalFeed < 1000) {
        result.value = '${totalFeed.toStringAsFixed(0)} جرام';
      } else {
        double totalFeedInKilo = totalFeed / 1000;
        result.value = '${totalFeedInKilo.toStringAsFixed(1)} كيلو';
      }
    }
  }

  void resetInputs() {
    isCumulative.value = !isCumulative.value;
    // إعادة تعيين العمر إلى null عند العودة إلى الحساب اليومي
    if (!isCumulative.value) {
      selectedAge.value = null;
    }
    result.value = ''; // إلغاء النتيجة عند التبديل
    _resetResultMessage();
    FocusScope.of(Get.context!).unfocus();
  }

  void _resetResultMessage() {
    if (textController.text.isEmpty) {
      result.value = '';
    }
  }
}
