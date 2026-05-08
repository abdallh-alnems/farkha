import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../data/model/cycle/mortality_entry.dart';

class MortalityEntryItem extends StatelessWidget {
  final MortalityEntry entry;
  final bool showDelete;
  final VoidCallback? onDelete;

  const MortalityEntryItem({
    super.key,
    required this.entry,
    this.showDelete = true,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.8),
                ]
              : [
                  colorScheme.primary.withValues(alpha: 0.08),
                  colorScheme.primary.withValues(alpha: 0.04),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 2.5.w,
            height: 32.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2.r),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.count}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        height: 1,
                        color: colorScheme.primary,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 1.5.h,
                        right: 3.w,
                      ),
                      child: Text(
                        'فرخ',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 9.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      DateFormat('yyyy-MM-dd').format(entry.date),
                      style: TextStyle(
                        fontSize: 9.sp,
                        color:
                            colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showDelete)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(6.r),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 14.sp,
                    color: colorScheme.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MortalityHistoryList extends StatelessWidget {
  final List<MortalityEntry> sortedEntries;
  final bool isViewer;
  final void Function(MortalityEntry) onDelete;

  const MortalityHistoryList({
    super.key,
    required this.sortedEntries,
    required this.isViewer,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sortedEntries.asMap().entries.map((entryMap) {
        final index = entryMap.key;
        final entry = entryMap.value;
        return Container(
          margin: EdgeInsets.only(
            bottom: 4.h,
            left: 12.w,
            right: 12.w,
            top: index == 0 ? 12.h : 0,
          ),
          child: MortalityEntryItem(
            entry: entry,
            showDelete: !isViewer,
            onDelete: () => onDelete(entry),
          ),
        );
      }).toList(),
    );
  }
}
