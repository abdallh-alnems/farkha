import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../data/model/cycle/medication_entry.dart';

class MedicationEntryItem extends StatelessWidget {
  final MedicationEntry entry;
  final bool isDark;
  final bool showDelete;
  final VoidCallback? onDelete;

  const MedicationEntryItem({
    super.key,
    required this.entry,
    required this.isDark,
    this.showDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
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
          color: isDark
              ? colorScheme.outline.withValues(alpha: 0.3)
              : colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _buildSideBar(colorScheme),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.text,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: colorScheme.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                _buildDateRow(colorScheme),
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

  Widget _buildSideBar(ColorScheme colorScheme) {
    return Container(
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
    );
  }

  Widget _buildDateRow(ColorScheme colorScheme) {
    return Row(
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
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class MedicationHistoryList extends StatelessWidget {
  final List<MedicationEntry> sortedEntries;
  final bool isDark;
  final bool isViewer;
  final void Function(MedicationEntry entry) onDeleteEntry;

  const MedicationHistoryList({
    super.key,
    required this.sortedEntries,
    required this.isDark,
    required this.isViewer,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...sortedEntries.asMap().entries.map((entryMap) {
          final index = entryMap.key;
          final entry = entryMap.value;
          return Container(
            margin: EdgeInsets.only(
              bottom: 4.h,
              left: 12.w,
              right: 12.w,
              top: index == 0 ? 12.h : 0,
            ),
            child: MedicationEntryItem(
              entry: entry,
              isDark: isDark,
              showDelete: !isViewer,
              onDelete: () => onDeleteEntry(entry),
            ),
          );
        }),
      ],
    );
  }
}
