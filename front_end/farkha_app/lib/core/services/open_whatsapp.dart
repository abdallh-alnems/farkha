import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/snackbar_message.dart';

Future<void> openWhatsApp() async {
  try {
    final Uri whatsappUri = Uri.parse('https://wa.me/201500998095');

    final bool launched = await launchUrl(
      whatsappUri,
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
      'لا يمكن فتح تطبيق واتساب',
      icon: Icons.error_outline,
    );
  }
}
