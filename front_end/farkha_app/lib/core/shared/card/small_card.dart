import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/theme/color.dart';
import '../../constant/theme/image_asset.dart';

class SmallCard extends StatelessWidget {
  final String image;
  final String text;

  const SmallCard({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 101.w,
      height: 87.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7).r,
        color: AppColor.secondaryColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            image,
            scale: 2.5.sp,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
