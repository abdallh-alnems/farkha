import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/snackbar_message.dart';

const String _privacyPolicyUrl =
    'https://www.nims-farkha.com/privacy-policy';

Future<void> openPrivacyPolicy() async {
  try {
    final Uri policyUri = Uri.parse(_privacyPolicyUrl);
    final bool launched = await launchUrl(
      policyUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      _showErrorMessage();
    }
  } catch (_) {
    _showErrorMessage();
  }
}

void _showErrorMessage() {
  final BuildContext? context = Get.context;
  if (context != null) {
    SnackbarMessage.show(
      context,
      'لا يمكن فتح سياسة الخصوصية',
      icon: Icons.error_outline,
    );
  }
}

