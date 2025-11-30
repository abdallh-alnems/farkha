import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/functions/handing_data_controller.dart';
import '../../data/data_source/remote/suggestion_data.dart';

class SuggestionController extends GetxController {
  StatusRequest statusRequest = StatusRequest.none;
  final SuggestionData suggestionData = SuggestionData(Get.find());
  bool isSuggestionSent = false;

  Future<void> addSuggestion(String suggestionText) async {
    statusRequest = StatusRequest.loading;
    isSuggestionSent = false;
    update();

    final dynamic response = await suggestionData.addSuggestion(
      suggestionText.trim(),
    );
    statusRequest = handlingData(response);

    if (response['status'] != "success") {
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    isSuggestionSent = true;
    statusRequest = StatusRequest.success;
    update();
  }

  void resetState() {
    if (!isSuggestionSent && statusRequest != StatusRequest.failure) {
      return;
    }
    isSuggestionSent = false;
    if (statusRequest != StatusRequest.loading) {
      statusRequest = StatusRequest.none;
    }
    update();
  }
}
