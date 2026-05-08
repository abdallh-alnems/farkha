import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/shared/price_change.dart';
import '../../../logic/controller/price_controller/price_history_controller.dart';

class PriceHistoryFilterSheet extends StatelessWidget {
  const PriceHistoryFilterSheet({
    super.key,
    required this.controller,
    required this.parentContext,
  });

  final PriceHistoryController controller;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.xl + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'بحث بالتاريخ',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          _FilterOption(
            icon: Icons.calendar_today_rounded,
            label: 'يوم محدد',
            onTap: () {
              Navigator.pop(context);
              _pickDay();
            },
            colorScheme: colorScheme,
            theme: theme,
          ),
          SizedBox(height: AppSpacing.sm),
          _FilterOption(
            icon: Icons.date_range_rounded,
            label: 'فترة زمنية',
            onTap: () {
              Navigator.pop(context);
              _pickRange();
            },
            colorScheme: colorScheme,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: parentContext,
      initialDate: controller.filterStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      controller.setFilter(start: picked, end: picked);
    }
  }

  Future<void> _pickRange() async {
    final start = await showDatePicker(
      context: parentContext,
      initialDate: controller.filterStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      helpText: 'اختر تاريخ البدء',
      builder: _dialogBuilder,
    );
    if (start == null || !parentContext.mounted) return;

    final startLabel = '${start.day}/${start.month}/${start.year}';
    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(
        content: Text('تم اختيار $startLabel كتاريخ بدء'),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (!parentContext.mounted) return;

    final end = await showDatePicker(
      context: parentContext,
      initialDate: start,
      firstDate: start,
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      helpText: 'اختر تاريخ الانتهاء',
      builder: _dialogBuilder,
    );
    if (end == null) return;

    controller.setFilter(start: start, end: end);
  }

  Widget _dialogBuilder(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(parentContext).copyWith(
        textTheme: Theme.of(parentContext).textTheme.copyWith(
          headlineSmall: Theme.of(parentContext).textTheme.headlineSmall?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppDimens.borderSm,
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: colorScheme.primary),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceHistoryRow extends StatelessWidget {
  const PriceHistoryRow({
    super.key,
    required this.item,
    required this.priceDiff,
    required this.showBoth,
  });

  final Map<String, dynamic> item;
  final double? priceDiff;
  final bool showBoth;

  static const _arabicDays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
    'الجمعة', 'السبت', 'الأحد',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final rawDate = (item['override_date'] ?? item['date'] ?? '').toString();
    final higher = (item['higher'] ?? '-').toString();
    final lower = (item['lower'] ?? '-').toString();
    final hasChange = priceDiff != null && priceDiff != 0;

    final parsedDate = _parseDate(rawDate);
    final displayDate = _formatDate(rawDate);
    final dayName = parsedDate != null ? _getDayName(parsedDate) : '';

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.25),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (dayName.isNotEmpty)
                    Text(
                      dayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
            if (showBoth)
              Expanded(
                child: Text(
                  lower,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            Expanded(
              child: Text(
                higher,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: hasChange
                    ? PriceChangeWidget(priceDifference: priceDiff!)
                    : Text(
                        '-',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    final datePart = raw.split(' ').first;
    return DateTime.tryParse(datePart);
  }

  String _getDayName(DateTime date) {
    final weekday = date.weekday;
    if (weekday >= 1 && weekday <= 7) return _arabicDays[weekday - 1];
    return '';
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    final datePart = raw.split(' ').first;
    final segments = datePart.split('-');
    if (segments.length >= 3) {
      return '${segments[2]}/${segments[1]}/${segments[0]}';
    }
    return raw;
  }
}
