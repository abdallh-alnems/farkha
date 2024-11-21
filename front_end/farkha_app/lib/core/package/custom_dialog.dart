import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DialogHelper {
  static void showDialog({required String middleText}) {
    Get.defaultDialog(
      title: "تنبيه",
      content: Container(
        constraints: BoxConstraints(maxHeight: 400.h),
        child: SingleChildScrollView(
          child: Text(
            middleText,
            textAlign: TextAlign.center,
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
