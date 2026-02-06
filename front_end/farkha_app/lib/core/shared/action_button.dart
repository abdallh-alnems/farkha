import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constant/theme/colors.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final void Function() onTap;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  const ActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 41.h;
    final effectivePadding =
        padding ?? EdgeInsets.symmetric(vertical: 11.h, horizontal: 33.w);
    final effectiveFontSize = fontSize ?? 17.sp;

    return Padding(
      padding: effectivePadding,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                text,
                style: TextStyle(fontSize: effectiveFontSize, color: Colors.white),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
