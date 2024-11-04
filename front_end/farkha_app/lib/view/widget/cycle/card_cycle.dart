import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/color.dart';
import '../../../core/constant/theme/image_asset.dart';

class CardCycle extends StatelessWidget {
  const CardCycle({super.key});

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            AppImageAsset.addCycle,
            scale: 2.3.sp,
          ),
          Text(
            "اضف دورة",
            style: TextStyle(
                fontSize: 17.sp,
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
