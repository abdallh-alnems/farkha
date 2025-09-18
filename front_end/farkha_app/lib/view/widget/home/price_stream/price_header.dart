import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constant/image_asset.dart';
import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/theme/color.dart';

class PriceHeader extends StatelessWidget {
  const PriceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.toNamed(AppRoute.customizePrices),
          child: SvgPicture.asset(
            ImageAsset.settingCardPrices,
            width: 23,
            height: 23,
          ),
        ),

        Expanded(
          child: Text(
            "أسعار البورصة",
            style: TextStyle(
              color: Colors.black,
              fontSize: 19.sp,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        GestureDetector(
          onTap: () => Get.toNamed(AppRoute.mainTypes),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "جميع الأسعار",
              style: TextStyle(color: Colors.white, fontSize: 13.sp),
            ),
          ),
        ),
      ],
    );
  }
}
