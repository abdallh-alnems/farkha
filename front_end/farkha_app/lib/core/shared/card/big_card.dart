import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/theme/color.dart';
import '../../constant/theme/image_asset.dart';

class BigCard extends StatelessWidget {
  final String image;
  final String text;
  const BigCard({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 151.w,
      height: 111.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: AppColor.secondaryColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            image,
            scale: 2.1.sp,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
