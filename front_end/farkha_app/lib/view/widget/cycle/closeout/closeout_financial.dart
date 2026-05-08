import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/theme.dart';
import 'closeout_data.dart';

class CloseoutFinancialSummary extends StatelessWidget {
  final CloseoutData data;
  final bool isDark;

  const CloseoutFinancialSummary(
      {super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? AppColors.darkSurfaceElevatedColor
        : AppColors.lightCardBackgroundColor;
    final dimColor =
        isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;
    final isProfit = data.netProfit >= 0;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: dimColor),
      ),
      child: Column(
        children: [
          _finRow('إجمالي المصروفات',
              '${data.totalExpenses.toStringAsFixed(0)} ج.م', isDark,
              valueColor: AppColors.errorColor),
          SizedBox(height: 10.h),
          _finRow('إجمالي المبيعات',
              '${data.totalSales.toStringAsFixed(0)} ج.م', isDark,
              valueColor: AppColors.successColor),
          SizedBox(height: 10.h),
          _finRow('إجمالي اللحم المنتج',
              '${data.totalMeat.toStringAsFixed(0)} كجم', isDark),
          SizedBox(height: 14.h),
          Container(height: 1, color: dimColor),
          SizedBox(height: 14.h),
          _finRow(
            'صافي الربح / الخسارة',
            '${isProfit ? '+' : ''}${data.netProfit.toStringAsFixed(0)} ج.م',
            isDark,
            valueColor: isProfit ? AppColors.successColor : AppColors.errorColor,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _finRow(String label, String value, bool isDark,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
