import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/theme.dart';

const _surfaceWarm = Color(0xFF2A2520);
const _surfaceBorder = Color(0xFF3D3630);
const _textPrimary = Color(0xFFF0EAE0);
const _textSecondary = Color(0xFFB8AE9E);
const _textMuted = Color(0xFF7A7268);

class DarknessAlarmInfoPanel extends StatelessWidget {
  final String? startTime;
  final String? endTime;
  final String? duration;
  final int? phase;
  final int? totalPhases;
  final Color accentColor;

  const DarknessAlarmInfoPanel({
    super.key,
    this.startTime,
    this.endTime,
    this.duration,
    this.phase,
    this.totalPhases,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTimeInfo = startTime != null;
    final bool hasPhaseInfo = phase != null && totalPhases != null;
    final bool hasDuration = duration != null;

    if (!hasTimeInfo && !hasPhaseInfo && !hasDuration) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _surfaceWarm,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Column(
        children: [
          if (hasTimeInfo)
            _buildInfoRow(
              icon: Icons.schedule_rounded,
              label: 'وقت الإظلام',
              value: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  endTime != null
                      ? '$startTime  →  $endTime'
                      : startTime!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
          if (hasDuration) ...[
            if (hasTimeInfo) _buildDivider(),
            _buildInfoRow(
              icon: Icons.timelapse_rounded,
              label: 'مدة هذه المرحلة',
              value: Text(
                duration!,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ),
          ],
          if (hasPhaseInfo) ...[
            if (hasTimeInfo || hasDuration) _buildDivider(),
            _buildPhaseRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Widget value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.sp, color: accentColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _textMuted,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 2.h),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
                child: value,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseRow() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.layers_rounded, size: 20.sp, color: accentColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تقدم المراحل',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _textMuted,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'المرحلة $phase من $totalPhases',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final p = phase ?? 1;
    final t = totalPhases ?? 1;
    final barWidth = 72.w;
    final filledFraction = p / t;

    return SizedBox(
      width: barWidth,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: SizedBox(
              height: 6.h,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: filledFraction,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$p/$t',
            style: TextStyle(
              fontSize: 10.sp,
              color: _textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Container(
        height: 1,
        color: _surfaceBorder.withValues(alpha: 0.6),
      ),
    );
  }
}

class DarknessAlarmActions extends StatelessWidget {
  final Color accentColor;
  final bool isFinish;
  final VoidCallback onStart;
  final VoidCallback onLater;

  const DarknessAlarmActions({
    super.key,
    required this.accentColor,
    required this.isFinish,
    required this.onStart,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: FilledButton.icon(
            onPressed: onStart,
            icon: Icon(
              isFinish
                  ? Icons.check_circle_outline_rounded
                  : Icons.dark_mode_rounded,
              size: 22.sp,
            ),
            label: Text(
              isFinish ? 'حسناً' : 'ابدء الإظلام',
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isFinish ? AppColors.successColor : accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimens.borderLg,
              ),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: TextButton(
            onPressed: onLater,
            style: TextButton.styleFrom(
              foregroundColor: _textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimens.borderLg,
                side: const BorderSide(color: _surfaceBorder),
              ),
            ),
            child: Text(
              'لاحقاً',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
