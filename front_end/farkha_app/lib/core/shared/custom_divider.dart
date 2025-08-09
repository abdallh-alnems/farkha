import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constant/theme/color.dart';

class CustomDivider extends StatelessWidget {
  final String text;
  final VoidCallback? onViewAllPressed;

  const CustomDivider({super.key, required this.text, this.onViewAllPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Row(
        children: [
          // كلمة "عرض الكل" في اليسار
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 5).r,
            child: GestureDetector(
              onTap: onViewAllPressed,
              child: Text(
                "عرض الكل",
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // الخط الأيسر
          Expanded(
            flex: 1,
            child: Container(height: 2, color: AppColor.primaryColor),
          ),

          // كلمة "احسب" في المنتصف
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5).r,
            child: Text(
              text,
              style: TextStyle(color: AppColor.primaryColor, fontSize: 17.sp),
            ),
          ),

          // الخط الأيمن
          Expanded(
            flex: 2,
            child: Container(height: 2, color: AppColor.primaryColor),
          ),
        ],
      ),
    );
  }
}
