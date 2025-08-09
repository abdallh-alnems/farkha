import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/status_request.dart';
import '../../core/functions/handing_data_controller.dart';
import '../../core/package/custom_snack_bar.dart';
import '../../data/data_source/remote/suggestion_data.dart';

class SuggestionController extends GetxController {
  late StatusRequest statusRequest = StatusRequest.none;
  SuggestionData suggestionData = SuggestionData(Get.find());

  Future<void> addSuggestion(String suggestionText) async {
    statusRequest = StatusRequest.loading;
    dynamic response = await suggestionData.addSuggestion(suggestionText);
    statusRequest = handlingData(response);
    if (response['status'] == "success") {
      CustomSnackbar(
        message: "تم ارسال الاقتراح",
        icon: Icons.check,
      ).show(Get.context!);
      Get.back();
      Get.back();
    } else {
      statusRequest = StatusRequest.failure;
    }
    update();
  }
}
