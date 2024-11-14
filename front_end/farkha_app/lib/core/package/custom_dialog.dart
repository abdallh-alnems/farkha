import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogHelper {
  static void showDialog({required String middleText}) {
    Get.defaultDialog(
      title: "تنبيه",
      middleText: middleText,
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: const Text("فهمت ذلك"),
      ),
    );
  }
}
