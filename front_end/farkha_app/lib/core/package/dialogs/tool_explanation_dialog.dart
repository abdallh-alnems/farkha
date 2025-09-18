import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/data_source/static/messages/tool_explanation_message.dart';

class ToolExplanationDialog {
  // عرض dialog اسم الأداة
  static void showDialog({required String toolKey}) {
    final message = ToolExplanationMessage.messages.firstWhere(
      (message) => message['key'] == toolKey,
      orElse: () => {'name': 'أداة غير معروفة', 'key': 'unknown'},
    );

    Get.defaultDialog(
      title: message['name'] ?? 'أداة غير معروفة',
      titleStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      content: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Text(
          message['message'] ?? 'أداة غير معروفة',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.9,
            color: Colors.black,
          ),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          FocusScope.of(Get.context!).unfocus();
        },
       
        child: const Text("فهمت ذلك"),
      ),
    );
  }
}
