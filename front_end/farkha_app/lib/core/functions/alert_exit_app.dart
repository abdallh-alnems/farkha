import 'package:farkha_app/core/constant/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColor.primaryColor,
                content: Center(
                  child: Text(
                    "! اضغط مرة اخري للخروج",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                elevation: 0,
                  margin: EdgeInsets.symmetric(
                    vertical:  65,
                    horizontal: 81).r,
                
              ),
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
