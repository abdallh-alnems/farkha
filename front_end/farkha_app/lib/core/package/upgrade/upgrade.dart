import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';
import 'check_min_version.dart';
import 'messages.dart';

class Upgrade extends StatelessWidget {
  final Widget child;

  const Upgrade({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final versionController = Get.find<MinVersionController>();

    return Obx(() {
      String minVersion = versionController.minAppVersion.value;
      bool showUpgrade = versionController.showUpgradeMessage.value;

      return Stack(
        children: [
          child,
          if (showUpgrade) _buildUpgradeAlert(minVersion),
        ],
      );
    });
  }

  Widget _buildUpgradeAlert(String minVersion) {
    return UpgradeAlert(
      upgrader: Upgrader(
          minAppVersion: minVersion,
          messages: UpgradeMessages(),
          durationUntilAlertAgain: const Duration(days: 10)),
      showIgnore: false,
    );
  }
}
