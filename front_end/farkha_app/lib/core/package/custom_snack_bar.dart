import 'package:farkha_app/core/constant/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSnackbar {
  final String message;
  final IconData? icon;

  CustomSnackbar({
    required this.message,
    required this.icon,
  });

  void show(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 19.sp,
            ),
            SizedBox(width: 17.w),
            Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
            ),
          ],
        ),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColor.primaryColor,
        margin: EdgeInsets.symmetric(vertical: 75, horizontal: 67).r,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(11), 
        ),
      ),
    );
  }
}
