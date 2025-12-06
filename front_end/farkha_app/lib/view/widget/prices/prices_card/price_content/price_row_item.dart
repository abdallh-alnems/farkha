import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constant/theme/colors.dart';
import '../../../../../core/shared/price_change.dart';

class PriceRowItem extends StatelessWidget {
  final String title;
  final String higherPrice;
  final String lowerPrice;
  final double priceDifference;

  const PriceRowItem({
    super.key,
    required this.title,
    required this.higherPrice,
    required this.lowerPrice,
    required this.priceDifference,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color titleColor = colorScheme.onSurface;
    final Color labelColor = titleColor.withValues(alpha: 0.7);
    final Color containerColor =
        isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor;
    final Color borderColor = isDark
        ? AppColors.darkOutlineColor.withValues(alpha: 0.8)
        : AppColors.lightOutlineColor.withValues(alpha: 0.9);
    // التحقق من أن lower_today يساوي null أو فارغ
    final bool showOnlyPrice = lowerPrice.isEmpty || lowerPrice == 'null';

    final List<Widget> priceColumns =
        showOnlyPrice
            ? [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      "السعر",
                      style: TextStyle(color: labelColor, fontSize: 11.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      higherPrice,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ]
            : [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "أقل",
                      style: TextStyle(color: labelColor, fontSize: 11.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      lowerPrice,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "أعلى",
                      style: TextStyle(color: labelColor, fontSize: 11.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      higherPrice,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 13),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
          ...priceColumns,
          Expanded(
            child: Column(
              children: [
                Text(
                  "التغير",
                  style: TextStyle(color: labelColor, fontSize: 11.sp),
                ),
                const SizedBox(height: 4),
                PriceChangeWidget(priceDifference: priceDifference),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
