import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../package/snackbar_message.dart';

class TapToExit extends StatelessWidget {
  const TapToExit({super.key, required this.child, this.snackBar});

  final Widget child;
  final SnackBar? snackBar;

  @override
  Widget build(BuildContext context) {
    DateTime? currentBackPressTime;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
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
