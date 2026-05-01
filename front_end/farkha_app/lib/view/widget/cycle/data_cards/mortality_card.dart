import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constant/strings/app_strings.dart';
import '../../../../data/model/cycle/mortality_entry.dart';
import '../../../../logic/controller/cycle_controller.dart';

class MortalityCard extends StatefulWidget {
  const MortalityCard({super.key});

  @override
  State<MortalityCard> createState() => _MortalityCardState();
}

class _MortalityCardState extends State<MortalityCard> {
  late final CycleController cycleCtrl;
  late final TextEditingController _controller;
  final _isHistoryExpanded = false.obs;

  bool get _isViewer =>
      cycleCtrl.currentCycle['role']?.toString() == 'viewer';

  int get _currentMortalityTotal {
    final cycle = cycleCtrl.currentCycle;
    return int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    cycleCtrl = Get.find<CycleController>();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colorScheme = Theme.of(context).colorScheme;
      final isDark = colorScheme.brightness == Brightness.dark;
      final cycle = cycleCtrl.currentCycle;
      final entries = cycleCtrl.getMortalityEntries();
      final lastEntry = entries.isNotEmpty ? entries.last : null;
      final sortedEntries = List<MortalityEntry>.from(entries)
        ..sort((a, b) => b.date.compareTo(a.date));
      final currentTotal = _currentMortalityTotal;
      final chickCount =
          int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
      final mortalityPercentage =
          chickCount > 0 ? (currentTotal / chickCount * 100) : 0.0;

      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: isDark
                    ? null
                    : LinearGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.15),
                              colorScheme.primary.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Icon(
                          Icons.cancel_outlined,
                          color: colorScheme.primary,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'عدد النافق',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.1,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      if (currentTotal > 0)
                        Row(
                          children: [
                            Text(
                              '$currentTotal',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(${mortalityPercentage.round()}%)',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      if (currentTotal > 0 && entries.length > 1)
                        SizedBox(width: 8.w),
                      if (entries.length > 1)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _isHistoryExpanded.value =
                                  !_isHistoryExpanded.value;
                            },
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: _isHistoryExpanded.value
                                    ? colorScheme.primary
                                        .withValues(alpha: 0.3)
                                    : colorScheme.primary
                                        .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                _isHistoryExpanded.value
                                    ? Icons.expand_less_rounded
                                    : Icons.history_rounded,
                                size: 14.sp,
                                color: colorScheme.primary,
                                shadows: [
                                  Shadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outline.withValues(alpha: 0.15),
            ),
            if (lastEntry != null && !_isHistoryExpanded.value)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
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
                              colorScheme.primary
                                  .withValues(alpha: 0.08),
                              colorScheme.primary
                                  .withValues(alpha: 0.04),
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
                              colorScheme.primary
                                  .withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.3),
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
                                  '${lastEntry.count}',
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
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                                  DateFormat('yyyy-MM-dd')
                                      .format(lastEntry.date),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!_isViewer)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _showDeleteConfirmDialog(lastEntry);
                            },
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.error.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(6.r),
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
                ),
              ),
            if (_isHistoryExpanded.value && entries.isNotEmpty) ...[
              ...sortedEntries.asMap().entries
                  .map((MapEntry<int, MortalityEntry> entryMap) {
                final index = entryMap.key;
                final entry = entryMap.value;
                return Container(
                  margin: EdgeInsets.only(
                    bottom: 4.h,
                    left: 12.w,
                    right: 12.w,
                    top: index == 0 ? 12.h : 0,
                  ),
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
                              colorScheme.primary
                                  .withValues(alpha: 0.08),
                              colorScheme.primary
                                  .withValues(alpha: 0.04),
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
                              colorScheme.primary
                                  .withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.3),
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
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
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
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                                  DateFormat('yyyy-MM-dd')
                                      .format(entry.date),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!_isViewer)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _showDeleteConfirmDialog(entry);
                            },
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.error.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(6.r),
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
              }),
            ],
            if (!_isViewer)
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? null
                      : LinearGradient(
                          colors: [
                            Colors.transparent,
                            colorScheme.primary
                                .withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'أدخل العدد',
                          hintStyle: TextStyle(
                            fontSize: 12.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          suffixText: 'فرخ',
                          suffixStyle: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Material(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10.r),
                      elevation: 2,
                      shadowColor: colorScheme.primary
                          .withValues(alpha: 0.3),
                      child: InkWell(
                        onTap: () {
                          final value = _controller.text;
                          final count = int.tryParse(value) ?? 0;
                          if (count > 0) {
                            _save();
                          } else {
                            _controller.clear();
                          }
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primary
                                    .withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: colorScheme.onPrimary,
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    final count = int.tryParse(value) ?? 0;
    if (count <= 0) return;
    await cycleCtrl.addMortalityEntry(count);
    _controller.clear();
  }

  void _showDeleteConfirmDialog(MortalityEntry entry) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog<void>(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          AppStrings.confirmDelete,
          style: TextStyle(
            color: colorScheme.primary,
          ),
        ),
        content: Text(
          'هل تريد حذف ${entry.count} فرخ من قسم عدد النافق؟',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              cycleCtrl.removeMortalityEntry(entry.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
              backgroundColor: colorScheme.error.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
