import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/theme/color.dart';
import '../../../core/constant/theme/imgae_asset.dart';

class CardPrice extends StatelessWidget {
  const CardPrice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 149.w,
      height: 45.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: AppColor.secondaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(
            AppImageAsset.price,
            scale: 1.9.sp,
          ),
          Text(
            "الاسعار",
            style: TextStyle(
                fontSize: 18.sp,
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
