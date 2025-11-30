import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';
import '../../logic/controller/get_min_version.dart';
import '../../data/data_source/static/messages/upgrade_messages.dart';

class Upgrade extends StatelessWidget {
  const Upgrade({super.key});

  @override
  Widget build(BuildContext context) {
    final versionController = Get.find<GetMinVersionController>();

    return FutureBuilder<void>(
      future: versionController.fetchMinAppVersion(),
      builder: (context, snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? UpgradeAlert(
                dialogStyle: UpgradeDialogStyle.cupertino,
                showIgnore: false,
                upgrader: Upgrader(
                  minAppVersion: versionController.minAppVersion,
                  messages: UpgradeMessages(),
                  durationUntilAlertAgain: const Duration(days: 17),
                ),
              )
            : const SizedBox();
      },
    );
  }
}
