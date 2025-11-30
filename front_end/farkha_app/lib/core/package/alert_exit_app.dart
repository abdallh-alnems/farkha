import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/snackbar_message.dart';

class TapToExit extends StatelessWidget {
  const TapToExit({super.key, required this.child, this.snackBar});

  final Widget child;
  final SnackBar? snackBar;

  static DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        DateTime now = DateTime.now();

        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 3)) {
          _lastBackPressTime = now;

          if (snackBar != null) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar!);
          } else {
            SnackbarMessage.show(
              context,
              "اضغط مرة اخري للخروج",
              icon: Icons.exit_to_app,
            );
          }
        } else {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
