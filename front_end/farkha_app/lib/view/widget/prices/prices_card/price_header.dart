import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../core/constant/theme/images.dart';

class PriceHeader extends StatelessWidget {
  final GlobalKey? allPricesButtonKey;
  final GlobalKey? settingsIconKey;

  const PriceHeader({super.key, this.allPricesButtonKey, this.settingsIconKey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;
    final List<Widget> baseChildren = [
      GestureDetector(
        onTap: () => Get.toNamed(AppRoute.mainTypes),
        child: Container(
          key: allPricesButtonKey,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "جميع الأسعار",
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
          ),
        ),
      ),

      Expanded(
        child: Text(
          "أسعار البورصة",
          style: TextStyle(
            color: onSurface,
            fontSize: 19.sp,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      GestureDetector(
        onTap: () => Get.toNamed(AppRoute.customizePrices),
        child: SvgPicture.asset(
          AppImages.settingCardPrices,
          key: settingsIconKey,
          width: 23,
          height: 23,
        ),
      ),
    ];

    return Row(children: baseChildren);
  }
}
