import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constant/theme/color.dart';

class CustomDivider extends StatelessWidget {
  final String text;
  const CustomDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              color: AppColor.primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 11, left: 11, bottom: 5).r,
            child: Text(
              text,
              style: TextStyle(color: AppColor.primaryColor, fontSize: 17.sp),
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
