import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/theme/theme.dart';
import 'comparison_widgets.dart';

class ComparisonSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<MetricDef> metrics;
  final List<Map<String, dynamic>> cycles;
  final Set<String> lowerIsBetter;

  const ComparisonSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.metrics,
    required this.cycles,
    this.lowerIsBetter = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.4),
        ),
        boxShadow: [
          AppElevation.shadow(
            opacity: colorScheme.brightness == Brightness.dark ? 0.0 : 0.06,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimens.radiusSm,
                    ),
                  ),
                  child: Icon(icon, size: 16.sp, color: colorScheme.primary),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...metrics.map(
            (m) => MetricRowWidget(
              metric: m,
              cycles: cycles,
              lowerIsBetter: lowerIsBetter.contains(m.key),
            ),
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }
}

class MetricRowWidget extends StatelessWidget {
  final MetricDef metric;
  final List<Map<String, dynamic>> cycles;
  final bool lowerIsBetter;

  const MetricRowWidget({
    super.key,
    required this.metric,
    required this.cycles,
    this.lowerIsBetter = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final winnerIndex = _findWinnerIndex();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 85.w,
            child: Text(
              metric.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ...cycles.asMap().entries.map((entry) {
            final i = entry.key;
            final cycle = entry.value;
            final isWinner = i == winnerIndex && cycles.length > 1;

            return Expanded(
              child: MetricValueCell(
                display: _formatValue(cycle),
                cycleColor: cycleColors[i % cycleColors.length],
                isWinner: isWinner,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatValue(Map<String, dynamic> cycle) {
    if (metric.isText) {
      return cycle[metric.key]?.toString() ?? '-';
    }
    final val =
        double.tryParse(cycle[metric.key]?.toString() ?? '0') ?? 0.0;
    String display;
    if (metric.isCount) {
      display = val.toInt().toString();
    } else if (val == val.truncateToDouble()) {
      display = val.toInt().toString();
    } else {
      display = val.toStringAsFixed(1);
    }
    if (metric.unit.isNotEmpty) display = '$display ${metric.unit}';
    return display;
  }

  int? _findWinnerIndex() {
    if (cycles.length < 2) return null;

    double? bestValue;
    int? bestIndex;

    for (int i = 0; i < cycles.length; i++) {
      if (metric.isText) continue;
      final val =
          double.tryParse(cycles[i][metric.key]?.toString() ?? '0') ?? 0.0;
      if (bestValue == null) {
        bestValue = val;
        bestIndex = i;
      } else {
        final isBetter = lowerIsBetter ? val < bestValue : val > bestValue;
        if (isBetter) {
          bestValue = val;
          bestIndex = i;
        }
      }
    }
    return bestIndex;
  }
}

class MetricValueCell extends StatelessWidget {
  final String display;
  final Color cycleColor;
  final bool isWinner;

  const MetricValueCell({
    super.key,
    required this.display,
    required this.cycleColor,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
      decoration: BoxDecoration(
        gradient: isWinner
            ? LinearGradient(
                colors: [
                  cycleColor.withValues(
                    alpha:
                        colorScheme.brightness == Brightness.dark
                            ? 0.12
                            : 0.08,
                  ),
                  cycleColor.withValues(
                    alpha:
                        colorScheme.brightness == Brightness.dark
                            ? 0.04
                            : 0.02,
                  ),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        color: isWinner
            ? null
            : colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: isWinner
            ? Border.all(color: cycleColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isWinner) ...[
            Icon(
              Icons.emoji_events_rounded,
              size: 12.sp,
              color: cycleColor,
            ),
            SizedBox(width: 3.w),
          ],
          Flexible(
            child: Text(
              display,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: isWinner ? FontWeight.w800 : FontWeight.w600,
                color: isWinner
                    ? cycleColor
                    : colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
