import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/theme/colors.dart';

class WeeklyData {
  final int mortality;
  final double avgWeight;
  final double totalFeed;
  final double totalWater;
  final double fcr;
  final double totalExpenses;
  final double totalSales;
  final double netProfit;
  final List<String> medications;
  final int daysWithData;

  WeeklyData({
    required this.mortality,
    required this.avgWeight,
    required this.totalFeed,
    required this.totalWater,
    required this.fcr,
    required this.totalExpenses,
    required this.totalSales,
    required this.netProfit,
    required this.medications,
    required this.daysWithData,
  });
}

class KpiItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;
  KpiItem(this.label, this.value, this.icon, [this.accentColor]);
}

class WeeklyReportHeader extends StatelessWidget {
  final String cycleName;
  final bool isDark;

  const WeeklyReportHeader({super.key, required this.cycleName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final dateFormat = DateFormat('d/M', 'ar');

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurfaceElevatedColor, AppColors.darkBackGroundColor]
              : [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.85)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'تقرير أسبوعي',
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.calendar_month_outlined, color: Colors.white, size: 22.sp),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            cycleName,
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '${dateFormat.format(weekStart)} — ${dateFormat.format(now)}',
              style: TextStyle(color: Colors.white, fontSize: 11.sp),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyReportEmptyState extends StatelessWidget {
  final bool isDark;
  const WeeklyReportEmptyState({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, size: 48.sp, color: Colors.grey[isDark ? 600 : 400]),
          SizedBox(height: 12.h),
          Text(
            'لا توجد بيانات مسجلة هذا الأسبوع',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 4.h),
          Text(
            'ابدأ بتسجيل البيانات اليومية لتظهر هنا',
            style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.grey[500] : Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class WeeklyReportSectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const WeeklyReportSectionTitle({super.key, required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: isDark ? AppColors.darkOutlineColor : Colors.grey[300])),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: isDark ? AppColors.darkOutlineColor : Colors.grey[300])),
        ],
      ),
    );
  }
}

class WeeklyReportKpiRow extends StatelessWidget {
  final List<KpiItem> items;
  final bool isDark;
  const WeeklyReportKpiRow({super.key, required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        final accentColor = item.accentColor ?? (isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor);
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceColor : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: isDark ? AppColors.darkOutlineColor : Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(item.icon, size: 18.sp, color: accentColor),
                SizedBox(height: 4.h),
                Text(
                  item.label,
                  style: TextStyle(fontSize: 9.5.sp, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                FittedBox(
                  child: Text(
                    item.value,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class WeeklyReportFinancialCard extends StatelessWidget {
  final WeeklyData data;
  final bool isDark;
  const WeeklyReportFinancialCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isDark ? AppColors.darkOutlineColor : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _finRow('المصروفات', '${data.totalExpenses.toStringAsFixed(0)} ج', isDark),
          if (data.totalSales > 0) _finRow('المبيعات', '${data.totalSales.toStringAsFixed(0)} ج', isDark),
          if (data.totalSales > 0) ...[
            Divider(color: isDark ? AppColors.darkOutlineColor : Colors.grey[300], height: 16.h),
            _finRow(
              'الصافي',
              '${data.netProfit >= 0 ? '+' : ''}${data.netProfit.toStringAsFixed(0)} ج',
              isDark,
              valueColor: data.netProfit >= 0 ? Colors.green : Colors.red,
              bold: true,
            ),
          ],
        ],
      ),
    );
  }

  static Widget _finRow(String label, String value, bool isDark, {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: bold ? FontWeight.bold : FontWeight.w600, color: valueColor ?? (isDark ? Colors.white : Colors.black87))),
        ],
      ),
    );
  }
}

class WeeklyReportMedicationsList extends StatelessWidget {
  final WeeklyData data;
  final bool isDark;
  const WeeklyReportMedicationsList({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? AppColors.darkOutlineColor : Colors.grey[200]!),
      ),
      child: Column(
        children: data.medications.map((med) => Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            children: [
              Icon(Icons.vaccines_outlined, size: 16.sp, color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor),
              SizedBox(width: 8.w),
              Expanded(child: Text(med, style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.white : Colors.black87))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
