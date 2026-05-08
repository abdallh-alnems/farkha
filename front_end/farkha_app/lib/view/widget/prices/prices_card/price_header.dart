import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/theme/images.dart';

class PriceHeader extends StatelessWidget {
  final GlobalKey? allPricesButtonKey;
  final GlobalKey? settingsIconKey;

  const PriceHeader({super.key, this.allPricesButtonKey, this.settingsIconKey});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;

    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'أسعار البورصة',
            style: TextStyle(
              color: onSurface,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed<void>(AppRoute.customizePrices),
          child: Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppImages.settingCardPrices,
              key: settingsIconKey,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
            ),
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: () => Get.toNamed<void>(AppRoute.mainTypes),
          child: Container(
            key: allPricesButtonKey,
            padding: EdgeInsetsDirectional.fromSTEB(10.w, 5.h, 10.w, 5.h),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'جميع الأسعار',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 9.sp,
                  color: colorScheme.onPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
