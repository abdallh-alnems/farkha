import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/functions/handing_data_controller.dart';
import '../../core/package/snackbar_message.dart';
import '../../data/data_source/remote/suggestion_data.dart';

class SuggestionController extends GetxController {
  late StatusRequest statusRequest = StatusRequest.none;
  SuggestionData suggestionData = SuggestionData(Get.find());

  Future<void> addSuggestion(String suggestionText) async {
    statusRequest = StatusRequest.loading;
    dynamic response = await suggestionData.addSuggestion(suggestionText);
    statusRequest = handlingData(response);
    if (response['status'] == "success") {
      SnackbarMessage.show(
        Get.context!,
        "تم ارسال الاقتراح",
        icon: Icons.check_circle,
      );
      Get.back();
      Get.back();
    } else {
      statusRequest = StatusRequest.failure;
    }
    update();
  }
}
