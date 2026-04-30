import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constant/storage_keys.dart';

class TimeSensitiveHintSheet extends StatelessWidget {
  const TimeSensitiveHintSheet({super.key});

  static Future<void> showIfNeeded() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    final storage = GetStorage();
    if (storage.read<bool>(StorageKeys.timeSensitiveHintShown) == true) return;

    storage.write(StorageKeys.timeSensitiveHintShown, true);
    await Get.bottomSheet<void>(
      const TimeSensitiveHintSheet(),
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 24.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(
            Icons.notifications_active_rounded,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            'تنبيهات مهمة على iPhone',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'حتى يخترق التنبيه وضع التركيز/Do Not Disturb على iPhone، فعّل خيار "Time Sensitive Notifications" لتطبيق فرخة من إعدادات iOS → الإشعارات → فرخة.',
            style: TextStyle(fontSize: 15, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.back<void>();
                openAppSettings();
              },
              icon: const Icon(Icons.settings_rounded),
              label: const Text('افتح الإعدادات'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('لاحقاً'),
          ),
        ],
      ),
    );
  }
}
