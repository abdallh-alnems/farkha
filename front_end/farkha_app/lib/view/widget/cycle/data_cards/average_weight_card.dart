import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constant/strings/app_strings.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../data/model/cycle/weight_entry.dart';
import '../../../../data/model/cycle/medication_entry.dart';
import '../../../../data/model/cycle/feed_consumption_entry.dart';
import '../../../../data/model/cycle/mortality_entry.dart';
import '../../../../logic/controller/cycle_controller.dart';

class AverageWeightCard extends StatefulWidget {
  final bool isDark;

  const AverageWeightCard({super.key, required this.isDark});

  @override
  State<AverageWeightCard> createState() => _AverageWeightCardState();
}

class _AverageWeightCardState extends State<AverageWeightCard> {
  late final CycleController cycleCtrl;
  late final TextEditingController _controller;
  final _isHistoryExpanded = false.obs;

  bool get _isViewer =>
      cycleCtrl.currentCycle['role']?.toString() == 'viewer';

  String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.round().toString();
    }
    return weight.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
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
      final isDark = widget.isDark;
      final entries = cycleCtrl.getAverageWeightEntries();
      final lastEntry = entries.isNotEmpty ? entries.last : null;
      final sortedEntries = List<WeightEntry>.from(entries)
        ..sort((a, b) => b.date.compareTo(a.date));

      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark
                ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
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
                          AppColors.primaryColor.withValues(alpha: 0.03),
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
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                AppColors.darkPrimaryColor
                                    .withValues(alpha: 0.2),
                                AppColors.darkPrimaryColor
                                    .withValues(alpha: 0.15),
                              ]
                            : [
                                AppColors.primaryColor
                                    .withValues(alpha: 0.15),
                                AppColors.primaryColor
                                    .withValues(alpha: 0.08),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.primaryColor
                                    .withValues(alpha: 0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Icon(
                      Icons.monitor_weight,
                      color: isDark
                          ? AppColors.darkPrimaryColor
                          : AppColors.primaryColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'متوسط وزن القطيع',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
                        color: isDark
                            ? AppColors.darkPrimaryColor
                            : AppColors.primaryColor,
                      ),
                    ),
                  ),
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
                                ? AppColors.primaryColor
                                    .withValues(alpha: 0.3)
                                : isDark
                                    ? AppColors.darkPrimaryColor
                                        .withValues(alpha: 0.25)
                                    : AppColors.primaryColor
                                        .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.primaryColor
                                  .withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            _isHistoryExpanded.value
                                ? Icons.expand_less_rounded
                                : Icons.history_rounded,
                            size: 14.sp,
                            color: isDark
                                ? AppColors.darkPrimaryColor
                                : AppColors.primaryColor,
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
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.15),
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
                              AppColors.darkSurfaceElevatedColor,
                              AppColors.darkSurfaceElevatedColor
                                  .withValues(alpha: 0.8),
                            ]
                          : [
                              AppColors.primaryColor
                                  .withValues(alpha: 0.08),
                              AppColors.primaryColor
                                  .withValues(alpha: 0.04),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkOutlineColor
                              .withValues(alpha: 0.3)
                          : AppColors.primaryColor
                              .withValues(alpha: 0.2),
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
                              AppColors.primaryColor,
                              AppColors.primaryColor
                                  .withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor
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
                                  _formatWeight(lastEntry.weight),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                    color: isDark
                                        ? AppColors.darkPrimaryColor
                                        : AppColors.primaryColor,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 1.5.h,
                                    right: 3.w,
                                  ),
                                  child: Text(
                                    'كيلو',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
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
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[500],
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  DateFormat('yyyy-MM-dd')
                                      .format(lastEntry.date),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
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
                                    Colors.red.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                size: 14.sp,
                                color: Colors.red[500],
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
                  .map((MapEntry<int, WeightEntry> entryMap) {
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
                              AppColors.darkSurfaceElevatedColor,
                              AppColors.darkSurfaceElevatedColor
                                  .withValues(alpha: 0.8),
                            ]
                          : [
                              AppColors.primaryColor
                                  .withValues(alpha: 0.08),
                              AppColors.primaryColor
                                  .withValues(alpha: 0.04),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkOutlineColor
                              .withValues(alpha: 0.3)
                          : AppColors.primaryColor
                              .withValues(alpha: 0.2),
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
                              AppColors.primaryColor,
                              AppColors.primaryColor
                                  .withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor
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
                                  _formatWeight(entry.weight),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                    color: isDark
                                        ? AppColors.darkPrimaryColor
                                        : AppColors.primaryColor,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 1.5.h,
                                    right: 3.w,
                                  ),
                                  child: Text(
                                    'كيلو',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
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
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[500],
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  DateFormat('yyyy-MM-dd')
                                      .format(entry.date),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
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
                                    Colors.red.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                size: 14.sp,
                                color: Colors.red[500],
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
                            AppColors.primaryColor
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
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        decoration: InputDecoration(
                          hintText: 'أدخل متوسط وزن القطيع',
                          hintStyle: TextStyle(
                            fontSize: 12.sp,
                            color:
                                isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceElevatedColor
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkOutlineColor
                                  : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkOutlineColor
                                  : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkPrimaryColor
                                  : AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          suffixText: 'كيلو',
                          suffixStyle: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkPrimaryColor
                              : Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Material(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10.r),
                      elevation: 2,
                      shadowColor: AppColors.primaryColor
                          .withValues(alpha: 0.3),
                      child: InkWell(
                        onTap: () {
                          final value = _controller.text;
                          final weight = double.tryParse(value) ?? 0.0;
                          if (weight > 0) {
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
                                AppColors.primaryColor,
                                AppColors.primaryColor
                                    .withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
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
    final weight = double.tryParse(value) ?? 0.0;
    if (weight <= 0) return;
    await cycleCtrl.addAverageWeightEntry(weight);
    _controller.clear();
  }

  void _showDeleteConfirmDialog(WeightEntry entry) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    Get.dialog<void>(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          AppStrings.confirmDelete,
          style: TextStyle(
            color:
                isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: Text(
          'هل تريد حذف ${_formatWeight(entry.weight)} كيلو من قسم متوسط وزن القطيع؟',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              cycleCtrl.removeAverageWeightEntry(entry.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withValues(alpha: 0.1),
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
