import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/data_source/static/messages/usage_tips_messages.dart';

class UsageTipsDialog {
  // الحصول على رسالة حسب مفتاح التخزين
  static Map<String, dynamic>? _getMessageByStorageKey(String storageKey) {
    try {
      return UsageTipsMessages.messages.firstWhere(
        (message) => message['storageKey'] == storageKey,
      );
    } catch (e) {
      return null;
    }
  }

  // عرض dialog مع رسالة مباشرة
  static void showDialog({required String middleText}) {
    Get.defaultDialog(
      title: "تنبيه",
      content: Container(
        constraints: BoxConstraints(maxHeight: 400.h),
        child: SingleChildScrollView(
          child: Text(middleText, textAlign: TextAlign.center),
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

  // عرض dialog النصائح إذا لم تكن معروضة من قبل
  static void showDialogIfNotShown(String storageKey) {
    if (GetStorage().read(storageKey) != false) {
      final message = _getMessageByStorageKey(storageKey);

      if (message != null) {
        showDialog(middleText: message['message']);
        GetStorage().write(storageKey, false);
      }
    }
  }
}
