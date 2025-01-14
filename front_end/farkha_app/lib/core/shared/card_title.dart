import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/color.dart';

class CardTitle extends StatelessWidget {
  final String text;
  final void Function() onTap;
  const CardTitle({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 33).r,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            width: double.infinity,
            height: 41,
            decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(13).r),
            child: Center(
                child: Text(
              text,
              style: TextStyle(fontSize: 17, color: Colors.white),
            ))),
      ),
    );
  }
}
