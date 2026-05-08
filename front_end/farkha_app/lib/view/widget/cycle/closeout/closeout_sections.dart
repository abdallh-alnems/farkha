import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/strings/app_strings.dart';
import '../../../../core/constant/theme/theme.dart';
import '../../../../core/shared/buttons/app_button.dart';
import '../../../../core/services/excel/excel_export_service.dart';
import '../../../../core/services/pdf/pdf_export_service.dart';
import '../../../../logic/controller/cycle_controller.dart';
import 'closeout_data.dart';

class CloseoutHeader extends StatelessWidget {
  final CloseoutData data;
  final bool isDark;

  const CloseoutHeader({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isProfit = data.netProfit >= 0;
    final trendIcon =
        isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final verdictLabel = isProfit ? 'ربح صافي' : 'خسارة صافية';

    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.darkSurfaceElevatedColor,
                    AppColors.darkBackGroundColor,
                  ]
                : [
                    AppColors.sunsetGradientStart,
                    AppColors.sunsetGradientEnd,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppDimens.radiusXl),
            bottomRight: Radius.circular(AppDimens.radiusXl),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back<void>(),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20.sp),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Spacer(),
                    Text(
                      'تقرير ختامي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  data.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  alignment: WrapAlignment.end,
                  children: [
                    _headerChip(
                        '${data.ageDays} يوم', Icons.calendar_today_outlined),
                    _headerChip(data.breed, Icons.category_outlined),
                    _headerChip(data.systemType, Icons.home_outlined),
                  ],
                ),
                SizedBox(height: 18.h),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              verdictLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${isProfit ? '+' : ''}${data.netProfit.toStringAsFixed(0)} ج.م',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(trendIcon, color: Colors.white, size: 28.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600)),
          SizedBox(width: 4.w),
          Icon(icon, color: Colors.white70, size: 12.sp),
        ],
      ),
    );
  }
}

class CloseoutExportSection extends StatelessWidget {
  final Map<String, dynamic> cycleData;

  const CloseoutExportSection({super.key, required this.cycleData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'PDF',
                icon: Icons.picture_as_pdf_outlined,
                variant: AppButtonVariant.outlined,
                onPressed: () async {
                  try {
                    await PdfExportService.exportCycleReport(cycleData);
                  } catch (e) {
                    Get.snackbar(AppStrings.error, 'فشل تصدير PDF',
                        backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AppButton(
                label: 'Excel',
                icon: Icons.table_chart_outlined,
                variant: AppButtonVariant.outlined,
                onPressed: () async {
                  try {
                    await ExcelExportService.exportCycleReport(cycleData);
                  } catch (e) {
                    Get.snackbar(AppStrings.error, 'فشل تصدير Excel',
                        backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        AppButton(
          label: 'إنهاء الدورة',
          icon: Icons.check_circle_outline,
          backgroundColor: AppColors.successColor,
          onPressed: () {
            _proceedToEndCycle();
            Get.back<void>();
          },
        ),
      ],
    );
  }

  void _proceedToEndCycle() {
    try {
      final controller = Get.find<CycleController>();
      unawaited(controller.endCurrentCycle());
    } catch (_) {}

    Get.back<void>();

    Future.delayed(const Duration(milliseconds: 600), () {
      try {
        final controller = Get.find<CycleController>();
        if (controller.cycles.isEmpty) {
          Get.back<void>();
        }
      } catch (_) {}
    });
  }
}

Widget closeoutSectionTitle(String title, bool isDark) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w800,
          color:
              isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
        ),
      ),
      SizedBox(width: 8.w),
      Container(
        width: 4.w,
        height: 18.h,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkPrimaryColor : AppColors.accentColor,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    ],
  );
}
