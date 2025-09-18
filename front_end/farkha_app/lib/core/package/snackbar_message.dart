import 'package:flutter/material.dart';

import '../constant/theme/color.dart';

class SnackbarMessage {
  static void show(
    BuildContext context,
    String message, {
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 21),
            const SizedBox(width: 15),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColor.primaryColor,
        margin: const EdgeInsets.symmetric(vertical: 75, horizontal: 43),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    );
  }
}
