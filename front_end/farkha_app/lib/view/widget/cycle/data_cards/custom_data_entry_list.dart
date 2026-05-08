import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../logic/controller/cycle_custom_data_controller.dart';
import 'custom_data_dialogs.dart';

class CustomDataEntryList extends StatelessWidget {
  final List<CustomDataEntry> sortedEntries;
  final CustomDataItem item;
  final int itemIndex;
  final bool isViewer;

  const CustomDataEntryList({
    super.key,
    required this.sortedEntries,
    required this.item,
    required this.itemIndex,
    required this.isViewer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 4.h),
      child: Column(
        children: sortedEntries.asMap().entries.map((mapEntry) {
          final entry = mapEntry.value;
          final isFirst = mapEntry.key == 0;
          return Padding(
            padding: EdgeInsets.only(top: isFirst ? 4.h : 6.h),
            child: _buildEntryRow(
              context,
              entry,
              isFirst,
              colorScheme,
              isDark,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEntryRow(
    BuildContext context,
    CustomDataEntry entry,
    bool isFirst,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isFirst
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 10.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat('yyyy-MM-dd').format(entry.date),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: colorScheme.onSurface
                            .withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isViewer)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final originalIndex = item.entries.indexWhere(
                    (e) => e.id == entry.id,
                  );
                  if (originalIndex != -1) {
                    showDeleteCustomEntryConfirmDialog(
                      context,
                      itemIndex,
                      originalIndex,
                      entry.text,
                      item.label,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(6.r),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14.sp,
                    color: colorScheme.error.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomDataSingleEntry extends StatelessWidget {
  final CustomDataEntry entry;
  final CustomDataItem item;
  final int itemIndex;
  final bool isViewer;

  const CustomDataSingleEntry({
    super.key,
    required this.entry,
    required this.item,
    required this.itemIndex,
    required this.isViewer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
              : colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.text,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 10.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.35),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        DateFormat('yyyy-MM-dd').format(entry.date),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isViewer)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final entryIndex =
                        item.entries.indexWhere((e) => e.id == entry.id);
                    if (entryIndex != -1) {
                      showDeleteCustomEntryConfirmDialog(
                        context,
                        itemIndex,
                        entryIndex,
                        entry.text,
                        item.label,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(6.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14.sp,
                      color: colorScheme.error.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget buildHistoryToggle(RxBool isExpanded, ColorScheme colorScheme) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => isExpanded.value = !isExpanded.value,
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(7.w),
        decoration: BoxDecoration(
          color: colorScheme.primary
              .withValues(alpha: isExpanded.value ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          isExpanded.value
              ? Icons.expand_less_rounded
              : Icons.history_rounded,
          size: 16.sp,
          color: colorScheme.primary,
        ),
      ),
    ),
  );
}

Widget buildActionIcon({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(7.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 16.sp, color: color),
      ),
    ),
  );
}
