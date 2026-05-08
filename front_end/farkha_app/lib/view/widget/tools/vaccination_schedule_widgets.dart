import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../data/data_source/static/vaccination_data.dart';
import '../../../data/model/vaccination_model.dart';

class VaccinationCurrentCard extends StatelessWidget {
  final VaccinationModel? vaccination;
  final int selectedAge;

  const VaccinationCurrentCard({
    super.key,
    required this.vaccination,
    required this.selectedAge,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasVaccine = vaccination != null;

    final activeColor =
        hasVaccine ? AppColors.primaryColor : AppColors.warningColor;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: isDark ? 0.15 : 0.06),
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: activeColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: AppDimens.borderSm,
                ),
                child: Icon(
                  hasVaccine
                      ? Icons.vaccines_outlined
                      : Icons.event_busy_outlined,
                  color: activeColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  hasVaccine
                      ? 'تحصين اليوم ${vaccination!.age} — مطلوب'
                      : 'لا يوجد تحصين لعمر $selectedAge يوم',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ),
          if (hasVaccine) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: AppDimens.borderMd,
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccination!.vaccineName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VaccinationNextCard extends StatelessWidget {
  final VaccinationModel vaccination;
  final int selectedAge;

  const VaccinationNextCard({
    super.key,
    required this.vaccination,
    required this.selectedAge,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysUntil = vaccination.age - selectedAge;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: AppDimens.borderSm,
                ),
                child: Icon(
                  Icons.upcoming_outlined,
                  color: AppColors.accentColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'التحصين القادم',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              VaccinationDaysChip(days: daysUntil),
            ],
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccination.vaccineName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'عمر ${vaccination.age} يوم',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VaccinationDaysChip extends StatelessWidget {
  final int days;

  const VaccinationDaysChip({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.accentColor.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: AppDimens.borderXl,
      ),
      child: Text(
        'بعد $days يوم',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.accentColor,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class VaccinationFullTimeline extends StatelessWidget {
  final int selectedAge;

  const VaccinationFullTimeline({super.key, required this.selectedAge});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schedule = VaccinationData.vaccinationSchedule;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
              : AppColors.lightOutlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: AppDimens.borderSm,
                ),
                child: Icon(
                  Icons.timeline_outlined,
                  color: AppColors.primaryColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'جدول التحصينات الكامل',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...List.generate(schedule.length, (index) {
            final vac = schedule[index];
            final isPast = vac.age < selectedAge;
            final isCurrent = vac.age == selectedAge;
            final isFuture = vac.age > selectedAge;
            final isLast = index == schedule.length - 1;

            return VaccinationTimelineItem(
              vaccination: vac,
              isPast: isPast,
              isCurrent: isCurrent,
              isFuture: isFuture,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

class VaccinationTimelineItem extends StatelessWidget {
  final VaccinationModel vaccination;
  final bool isPast;
  final bool isCurrent;
  final bool isFuture;
  final bool isLast;

  const VaccinationTimelineItem({
    super.key,
    required this.vaccination,
    required this.isPast,
    required this.isCurrent,
    required this.isFuture,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color dotColor;
    final Color lineColor;
    final IconData statusIcon;

    if (isPast) {
      dotColor = AppColors.primaryColor;
      lineColor = AppColors.primaryColor.withValues(alpha: 0.3);
      statusIcon = Icons.check_circle_outline;
    } else if (isCurrent) {
      dotColor = AppColors.accentColor;
      lineColor = AppColors.accentColor.withValues(alpha: 0.3);
      statusIcon = Icons.vaccines_outlined;
    } else {
      dotColor = colorScheme.outline.withValues(alpha: 0.5);
      lineColor = colorScheme.outline.withValues(alpha: 0.2);
      statusIcon = Icons.circle_outlined;
    }

    final nameColor =
        isPast
            ? colorScheme.onSurface.withValues(alpha: 0.5)
            : isCurrent
            ? AppColors.accentColor
            : colorScheme.onSurface;

    final ageLabelColor =
        isPast
            ? AppColors.primaryColor.withValues(alpha: 0.7)
            : isCurrent
            ? AppColors.accentColor
            : AppColors.secondaryColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42.w,
            child: Column(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: dotColor, width: 2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: isPast
                      ? Icon(Icons.check_rounded, size: 16.sp, color: dotColor)
                      : isCurrent
                      ? Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        )
                      : Icon(statusIcon, size: 14.sp, color: dotColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.w,
                      color: lineColor,
                      margin: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'يوم ${vaccination.age}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: ageLabelColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (isCurrent) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentColor.withValues(
                              alpha: isDark ? 0.2 : 0.1,
                            ),
                            borderRadius: AppDimens.borderXl,
                          ),
                          child: Text(
                            'اليوم',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    vaccination.vaccineName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                      color: nameColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
