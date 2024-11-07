import 'package:farkha_app/core/constant/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../package/custom_snck_bar.dart';

class TapToExit extends StatelessWidget {
  const TapToExit({
    super.key,
    required this.child,
    this.snackBar,
  });

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
            CustomSnackbar(
          message: "اضغط مرة اخري للخروج",
          icon: Icons.logout,
         
        ).show(context);
          }
        } else {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
