import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constant/theme/theme.dart';

class HistoryDetailsBottomSheets {
  static void openBottomSheet(
    BuildContext context,
    String title,
    Widget child,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    Get.bottomSheet<void>(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusXl),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 20.sp,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: colorScheme.outline.withValues(alpha: 0.3),
              height: 1,
            ),
            Expanded(child: child),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget buildExpensesList(
    Map<String, dynamic> cycle,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final expenses = (cycle['expenses'] as List?) ?? [];
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            SizedBox(height: 8.h),
            Text(
              'لا توجد مصروفات مسجلة',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final exp = expenses[index];
        final type = exp['type']?.toString() ?? 'أخرى';
        final amount =
            double.tryParse(exp['amount']?.toString() ?? '0') ?? 0.0;
        final rawDate = exp['created_at']?.toString() ?? '';
        final notes = exp['notes']?.toString() ?? '';

        String formattedDate = rawDate;
        if (formattedDate.isNotEmpty && !formattedDate.contains('/')) {
          try {
            final temp = DateTime.parse(rawDate);
            formattedDate = DateFormat('yyyy/MM/dd').format(temp);
          } catch (_) {}
        }

        final iconData = _getExpenseIcon(type);
        final iconColor = _getExpenseColor(type);

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            leading: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(iconData, color: iconColor, size: 20.sp),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getExpenseTypeNameAr(type),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(1)} ج',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.sp,
                    color: AppColors.errorColor,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
                if (notes.isNotEmpty && notes != 'null') ...[
                  SizedBox(height: 3.h),
                  Text(
                    notes,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static IconData _getExpenseIcon(String type) {
    if (type == 'feed' || type == 'علف') return Icons.agriculture_outlined;
    if (type == 'medicine' || type == 'adwya' || type == 'أدوية') {
      return Icons.medication_outlined;
    }
    if (type == 'chicks' || type == 'كتاكيت') return Icons.egg_outlined;
    if (type == 'labor' || type == 'amal') return Icons.engineering_outlined;
    return Icons.receipt_outlined;
  }

  static Color _getExpenseColor(String type) {
    if (type == 'feed' || type == 'علف') return AppColors.accentColor;
    if (type == 'medicine' || type == 'adwya' || type == 'أدوية') {
      return AppColors.infoColor;
    }
    if (type == 'chicks' || type == 'كتاكيت') return AppColors.secondaryColor;
    if (type == 'labor' || type == 'amal') return AppColors.primaryColor;
    return AppColors.darkSecondaryColor;
  }

  static String _getExpenseTypeNameAr(String type) {
    if (type == 'feed') return 'علف';
    if (type == 'medicine' || type == 'adwya') return 'أدوية وتحصينات';
    if (type == 'chicks') return 'كتاكيت';
    if (type == 'labor' || type == 'amal') return 'عمالة وإيجار';
    if (type == 'other') return 'أخرى';
    return type;
  }

  static Widget buildDailyRecordsList(
    Map<String, dynamic> cycle,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final feedEntries = (cycle['feedEntries'] as List?) ?? [];
    final mortalityEntries = (cycle['mortalityEntries'] as List?) ?? [];
    final weightEntries = (cycle['weightEntries'] as List?) ?? [];
    final customDataEntries = (cycle['customDataEntries'] as List?) ?? [];

    final allDates = <String>{};
    for (var e in feedEntries) {
      allDates.add(e['date']?.toString() ?? '');
    }
    for (var e in mortalityEntries) {
      allDates.add(e['date']?.toString() ?? '');
    }
    for (var e in weightEntries) {
      allDates.add(e['date']?.toString() ?? '');
    }
    for (var e in customDataEntries) {
      if (e['element_type'] == 'note') {
        allDates.add(e['date']?.toString() ?? '');
      }
    }
    allDates.removeWhere((e) => e.isEmpty);

    final sortedDates = allDates.toList()..sort();

    if (sortedDates.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 40.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            SizedBox(height: 8.h),
            Text(
              'لا توجد سجلات بيانات مسجلة',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        double tFeed = 0;
        int tMortality = 0;
        double tWeight = 0;
        final notes = <String>[];

        for (var e in feedEntries) {
          if (e['date'] == date && e['amount'] != null) {
            tFeed += double.tryParse(e['amount'].toString()) ?? 0;
          }
        }
        for (var e in mortalityEntries) {
          if (e['date'] == date && e['count'] != null) {
            tMortality += int.tryParse(e['count'].toString()) ?? 0;
          }
        }
        for (var e in weightEntries) {
          if (e['date'] == date && e['weight'] != null) {
            tWeight = double.tryParse(e['weight'].toString()) ?? 0;
          }
        }
        for (var e in customDataEntries) {
          if (e['date'] == date &&
              e['element_type'] == 'note' &&
              e['value'] != null) {
            notes.add(e['value'].toString());
          }
        }

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor
                      .withValues(alpha: isDark ? 0.08 : 0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimens.radiusMd),
                    topRight: Radius.circular(AppDimens.radiusMd),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_note_rounded,
                      size: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (tFeed > 0)
                          _buildDailyMetric(
                            'علف',
                            '${tFeed.toStringAsFixed(1)} كجم',
                            AppColors.accentColor,
                            colorScheme,
                          ),
                        if (tMortality > 0)
                          _buildDailyMetric(
                            'نافق',
                            '$tMortality طير',
                            AppColors.errorColor,
                            colorScheme,
                          ),
                        if (tWeight > 0)
                          _buildDailyMetric(
                            'وزن',
                            '${tWeight.toStringAsFixed(2)} كجم',
                            AppColors.infoColor,
                            colorScheme,
                          ),
                      ],
                    ),
                    if (tFeed <= 0 &&
                        tMortality <= 0 &&
                        tWeight <= 0 &&
                        notes.isEmpty)
                      Center(
                        child: Text(
                          'عنصر فارغ',
                          style: TextStyle(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    if (notes.isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      Divider(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        height: 1,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 13.sp,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'الملاحظات',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      ...notes.map(
                        (note) => Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\u2022 ',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 15.sp,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  note,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDailyMetric(
    String label,
    String value,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
