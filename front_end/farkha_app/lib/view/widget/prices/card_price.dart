import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/color.dart';
import '../../../core/constant/theme/image_asset.dart';

class CardPrice extends StatelessWidget {
  const CardPrice({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Get.snackbar(
                '',
                '',
                titleText: const Text(
                  '',
                  style: TextStyle(fontSize: 0),
                  textAlign: TextAlign.center,
                ),
                messageText: const Text(
                  'قريبا',
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              );
      },
      child: Container(
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
      ),
    );
  }
}
