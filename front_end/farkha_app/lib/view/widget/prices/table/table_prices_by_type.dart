import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/theme/theme.dart';
import '../../../../core/shared/price_change.dart';
import '../../../../logic/controller/price_controller/prices_by_type_controller.dart';

class TablePricesByType extends StatelessWidget {
  const TablePricesByType({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PricesByTypeController>(
      builder: (controller) {
        return HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: Column(
            children: [
              _buildHeader(context),
              SizedBox(height: AppSpacing.sm),
              ...controller.items.map((price) => _buildPriceCard(context, price)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusMd)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'النوع',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'أقل',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'أعلى',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'التغير',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, Map<String, dynamic> price) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final int typeId = (price['type_id'] as num?)?.toInt() ?? 0;
    final num lastHigherPrice = (price['today_higher_price'] as num?) ?? 0;
    final num lastLowerPrice = (price['today_lower_price'] as num?) ?? 0;
    final num yesterdayHigherPrice = (price['yesterday_higher_price'] as num?) ?? 0;
    final num yesterdayLowerPrice = (price['yesterday_lower_price'] as num?) ?? 0;
    final String typeName = (price['type_name'] ?? '').toString();

    final double currentAvgPrice = (lastHigherPrice + lastLowerPrice) / 2;
    final double yesterdayAvgPrice = (yesterdayHigherPrice + yesterdayLowerPrice) / 2;
    final double priceDifference = currentAvgPrice - yesterdayAvgPrice;
    final bool hasChange = priceDifference.abs() > 0;
    final bool isUp = priceDifference > 0;

    final VoidCallback? onTap =
        typeId > 0
            ? () {
                Get.toNamed<void>(
                  AppRoute.priceHistory,
                  arguments: {'type_id': typeId, 'type_name': typeName},
                );
              }
            : null;

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Material(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderSm,
        elevation: AppElevation.none,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimens.borderSm,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            decoration: BoxDecoration(
              borderRadius: AppDimens.borderSm,
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 28.h,
                        decoration: BoxDecoration(
                          color: hasChange
                              ? (isUp ? AppColors.successColor : AppColors.errorColor)
                              : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          typeName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    lastLowerPrice.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    lastHigherPrice.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: PriceChangeWidget(priceDifference: priceDifference),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
