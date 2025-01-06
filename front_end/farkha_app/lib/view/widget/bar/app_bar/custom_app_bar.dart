import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/theme/color.dart';

class CustomAppBar extends StatelessWidget  {
  final String text;
  final bool arrowDirection;

  const CustomAppBar({
    super.key,
    this.arrowDirection = true,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 21).r,
        child: Align(
          alignment: Alignment.topCenter,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Align(
                alignment: arrowDirection
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: arrowDirection
                      ? EdgeInsets.only(left: 23).r
                      : EdgeInsets.only(right: 23).r,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: ClipOval(
                      child: Container(
                        width: 33,
                        height: 33,
                        color: AppColor.primaryColor,
                        child: Icon(
                          arrowDirection
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_right_alt,
                          color: Colors.white,
                          size: 23.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
