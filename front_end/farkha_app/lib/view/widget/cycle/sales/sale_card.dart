import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constant/theme/theme.dart';
import '../../../../logic/controller/cycle_sales_controller.dart';
import '../../../../view/widget/ad/native.dart';
import 'sales_dialogs.dart';

class SalesSection extends StatelessWidget {
  final CycleSalesController controller;
  final bool isViewer;

  const SalesSection({
    super.key,
    required this.controller,
    required this.isViewer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Obx(() {
      final sales = controller.sales;

      if (sales.isEmpty) {
        return _EmptyState(colorScheme: colorScheme);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Row(
              children: [
                Text(
                  'عمليات البيع',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color:
                        colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${sales.length}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...sales.asMap().entries.map((entry) {
            final index = entry.key;
            final sale = entry.value;
            return Column(
              children: [
                _SaleCard(
                  sale: sale,
                  controller: controller,
                  isViewer: isViewer,
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
                if (index == 0) ...[
                  SizedBox(height: 4.h),
                  const AdNativeWidget(),
                ],
                SizedBox(height: 12.h),
              ],
            );
          }),
        ],
      );
    });
  }
}

class _SaleCard extends StatelessWidget {
  final SalesItem sale;
  final CycleSalesController controller;
  final bool isViewer;
  final ColorScheme colorScheme;
  final bool isDark;

  const _SaleCard({
    required this.sale,
    required this.controller,
    required this.isViewer,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.15)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            sale: sale,
            controller: controller,
            isViewer: isViewer,
            colorScheme: colorScheme,
            isDark: isDark,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outline.withValues(alpha: 0.15),
          ),
          _CardPrice(sale: sale, colorScheme: colorScheme),
          _CardDetails(sale: sale, colorScheme: colorScheme, isDark: isDark),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final SalesItem sale;
  final CycleSalesController controller;
  final bool isViewer;
  final ColorScheme colorScheme;
  final bool isDark;

  const _CardHeader({
    required this.sale,
    required this.controller,
    required this.isViewer,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusLg),
          topRight: Radius.circular(AppDimens.radiusLg),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.15),
                  colorScheme.primary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppDimens.borderMd,
            ),
            child: Icon(Icons.sell_outlined,
                size: 18.sp, color: colorScheme.primary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              DateFormat('dd MMM yyyy').format(sale.saleDate),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          if (!isViewer)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () =>
                    showDeleteConfirmation(context, controller, sale),
                borderRadius: AppDimens.borderSm,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color:
                        colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: AppDimens.borderSm,
                  ),
                  child: Icon(Icons.delete_outline,
                      color: colorScheme.error, size: 18.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardPrice extends StatelessWidget {
  final SalesItem sale;
  final ColorScheme colorScheme;

  const _CardPrice({
    required this.sale,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            sale.totalPrice.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
              height: 1.1,
            ),
          ),
          SizedBox(width: 4.w),
          Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text(
              'جنيه',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color:
                    colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDetails extends StatelessWidget {
  final SalesItem sale;
  final ColorScheme colorScheme;
  final bool isDark;

  const _CardDetails({
    required this.sale,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : LinearGradient(
                colors: [
                  Colors.transparent,
                  colorScheme.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.radiusLg),
          bottomRight: Radius.circular(AppDimens.radiusLg),
        ),
      ),
      child: Row(
        children: [
          _detailChip(Icons.pets_outlined, '${sale.birdsCount}',
              'طائر', colorScheme, isDark),
          SizedBox(width: 8.w),
          _detailChip(Icons.scale_outlined,
              sale.totalWeight.toStringAsFixed(0), 'كجم', colorScheme, isDark),
          SizedBox(width: 8.w),
          _detailChip(Icons.attach_money,
              sale.pricePerKilo.toStringAsFixed(0), 'جـ/كجم', colorScheme, isDark),
        ],
      ),
    );
  }

  static Widget _detailChip(IconData icon, String value, String unit,
      ColorScheme colorScheme, bool isDark) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: colorScheme.primary
              .withValues(alpha: isDark ? 0.08 : 0.05),
          borderRadius: AppDimens.borderSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13.sp, color: colorScheme.primary),
            SizedBox(width: 4.w),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme colorScheme;

  const _EmptyState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color:
                    colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sell_outlined,
                size: 40.sp,
                color:
                    colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد عمليات بيع',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'أضف عملية بيع لتتبع مبيعات الدورة',
              style: TextStyle(
                fontSize: 13.sp,
                color:
                    colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
