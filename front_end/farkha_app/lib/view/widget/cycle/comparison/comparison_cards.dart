import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/theme.dart';
import 'comparison_widgets.dart';

class CycleSelectionCard extends StatelessWidget {
  final Map<String, dynamic> cycle;
  final bool isSelected;
  final int selectionIndex;
  final VoidCallback onTap;

  const CycleSelectionCard({
    super.key,
    required this.cycle,
    required this.isSelected,
    required this.selectionIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cycleColor = selectionIndex >= 0
        ? cycleColors[selectionIndex % cycleColors.length]
        : colorScheme.primary;

    final name = cycle['name']?.toString() ?? 'دورة بدون اسم';
    final chickCount = cycle['chickCount']?.toString() ?? '0';
    final breed = cycle['breed']?.toString() ?? '';
    final systemType = cycle['systemType']?.toString() ?? 'أرضي';
    final cycleAge = cycle['cycle_age']?.toString() ?? '0';
    final startDate = cycle['startDate']?.toString() ?? '-';
    final endDate = cycle['endDate']?.toString() ?? '-';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuart,
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isSelected
              ? cycleColor.withValues(
                  alpha:
                      colorScheme.brightness == Brightness.dark ? 0.12 : 0.06,
                )
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: isSelected
                ? cycleColor.withValues(alpha: 0.6)
                : colorScheme.outline.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cycleColor.withValues(
                      alpha:
                          colorScheme.brightness == Brightness.dark
                              ? 0.12
                              : 0.08,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  AppElevation.shadow(
                    opacity:
                        colorScheme.brightness == Brightness.dark ? 0.0 : 0.06,
                  ),
                ],
        ),
        child: Row(
          children: [
            SelectionIndicator(isSelected: isSelected, color: cycleColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 5.w,
                    runSpacing: 4.h,
                    children: [
                      InfoChip('$chickCount طائر'),
                      if (breed.isNotEmpty) InfoChip(breed),
                      InfoChip(systemType),
                      InfoChip('$cycleAge يوم'),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '$startDate  -  $endDate',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
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

class SelectionIndicator extends StatelessWidget {
  final bool isSelected;
  final Color color;

  const SelectionIndicator({
    super.key,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutQuart,
      width: 26.w,
      height: 26.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? color
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: isSelected
          ? Icon(Icons.check_rounded, size: 16.sp, color: Colors.white)
          : null,
    );
  }
}

class InfoChip extends StatelessWidget {
  final String text;

  const InfoChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: colorScheme.onSurface.withValues(alpha: 0.55),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class CycleHeaderRow extends StatelessWidget {
  final List<Map<String, dynamic>> cycles;

  const CycleHeaderRow({super.key, required this.cycles});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 85.w),
          ...cycles.asMap().entries.map((entry) {
            final i = entry.key;
            final name = entry.value['name']?.toString() ?? '-';
            final color = cycleColors[i % cycleColors.length];
            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                padding:
                    EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(
                        alpha: colorScheme.brightness == Brightness.dark
                            ? 0.15
                            : 0.12,
                      ),
                      color.withValues(
                        alpha: colorScheme.brightness == Brightness.dark
                            ? 0.06
                            : 0.04,
                      ),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
