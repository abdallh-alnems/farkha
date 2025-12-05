import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/snackbar_message.dart';

Future<void> openGmail() async {
  try {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@nims-farkha.com',
    );

    final bool launched = await launchUrl(
      emailLaunchUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      _showErrorMessage();
    }
  } catch (e) {
    _showErrorMessage();
  }
}

void _showErrorMessage() {
  final BuildContext? context = Get.context;
  if (context != null) {
    SnackbarMessage.show(
      context,
      'لا يمكن فتح تطبيق البريد الإلكتروني',
      icon: Icons.error_outline,
    );
  }
}