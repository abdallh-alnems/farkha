import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_custom_data_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/cycle/data_cards/average_weight_card.dart';
import '../../widget/cycle/data_cards/feed_consumption_card.dart';
import '../../widget/cycle/data_cards/medication_card.dart';
import '../../widget/cycle/data_cards/mortality_card.dart';

class CycleDataScreen extends StatefulWidget {
  const CycleDataScreen({super.key});

  @override
  State<CycleDataScreen> createState() => _CycleDataScreenState();
}

class _CycleDataScreenState extends State<CycleDataScreen> {
  late final CycleController cycleCtrl;
  late final CycleCustomDataController customDataCtrl;
  late final BroilerController broilerCtrl;

  bool get _isViewer => cycleCtrl.currentCycle['role']?.toString() == 'viewer';

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CycleController>()) {
      Get.put(CycleController());
    }
    if (!Get.isRegistered<BroilerController>()) {
      Get.put(BroilerController());
    }
    Get.put(CycleCustomDataController(), permanent: true);
    cycleCtrl = Get.find<CycleController>();
    customDataCtrl = Get.find<CycleCustomDataController>();
    broilerCtrl = Get.find<BroilerController>();

    final cycleId = cycleCtrl.currentCycle['cycle_id'];
    if (cycleId != null) {
      final cycleIdInt =
          cycleId is int ? cycleId : int.tryParse(cycleId.toString());
      if (cycleIdInt != null && cycleIdInt > 0) {
        cycleCtrl.fetchCycleDetails(cycleIdInt, silent: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackGroundColor : AppColors.appBackGroundColor,
      appBar: AppBar(
        backgroundColor:
            isDark
                ? AppColors.darkSurfaceElevatedColor
                : AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkPrimaryColor : Colors.white,
          ),
          onPressed: () => Get.back<void>(),
        ),
        title: Obx(() {
          final cycle = cycleCtrl.currentCycle;
          return Text(
            'إدخال بيانات ${cycle['name'] ?? 'الدورة'}',
            style: TextStyle(
              color: isDark ? AppColors.darkPrimaryColor : Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        centerTitle: true,
        actions: [
          if (cycleCtrl.currentCycle['role']?.toString() != 'viewer')
            IconButton(
              icon: Icon(
                Icons.add,
                color: isDark ? AppColors.darkPrimaryColor : Colors.white,
              ),
              onPressed: () => _showAddDataDialog(isDark),
            ),
        ],
      ),
      body: Obx(() {
        if (cycleCtrl.cycleDetailsStatus.value == StatusRequest.loading) {
          return const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => cycleCtrl.forceRefreshCurrentCycle(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MortalityCard(isDark: isDark),
                  SizedBox(height: 20.h),
                  AverageWeightCard(isDark: isDark),
                  SizedBox(height: 20.h),
                  const AdNativeWidget(),
                  SizedBox(height: 20.h),
                  MedicationCard(isDark: isDark),
                  SizedBox(height: 20.h),
                  FeedConsumptionCard(isDark: isDark),
                  Obx(() {
                    if (customDataCtrl.customDataItems.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        ...customDataCtrl.customDataItems.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final item = entry.value;
                          return Column(
                            children: [
                              SizedBox(height: 20.h),
                              _buildCustomDataCard(item, index, isDark),
                            ],
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  void _showAddDataDialog(bool isDark) {
    final nameController = TextEditingController();
    const IconData defaultIcon = Icons.note;

    Get.dialog<void>(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'إضافة بطاقة بيانات جديدة',
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : Colors.black87,
          ),
          decoration: InputDecoration(
            labelText: 'اسم البطاقة',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            filled: true,
            fillColor:
                isDark ? AppColors.darkSurfaceElevatedColor : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkOutlineColor : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkOutlineColor : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color:
                    isDark
                        ? AppColors.darkPrimaryColor
                        : AppColors.primaryColor,
                width: 2,
              ),
            ),
          ),
          autofocus: true,
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
              if (nameController.text.isNotEmpty) {
                customDataCtrl.addCustomDataItem(
                  nameController.text,
                  defaultIcon,
                );
                Get.back<void>();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor:
                  isDark
                      ? AppColors.darkPrimaryColor.withValues(alpha: 0.2)
                      : AppColors.primaryColor.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'إضافة',
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.darkPrimaryColor
                        : AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDataCard(CustomDataItem item, int itemIndex, bool isDark) {
    final textController = TextEditingController();
    final focusNode = FocusNode();
    final isHistoryExpanded = false.obs;

    return Obx(() {
      final entries = item.entries;
      final lastEntry = entries.isNotEmpty ? entries.last : null;
      final sortedEntries = List<CustomDataEntry>.from(entries)
        ..sort((a, b) => b.date.compareTo(a.date));

      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isDark
                    ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
          ),
          boxShadow:
              isDark
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
                gradient:
                    isDark
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
                        colors:
                            isDark
                                ? [
                                  AppColors.darkPrimaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  AppColors.darkPrimaryColor.withValues(
                                    alpha: 0.15,
                                  ),
                                ]
                                : [
                                  AppColors.primaryColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  AppColors.primaryColor.withValues(
                                    alpha: 0.08,
                                  ),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow:
                          isDark
                              ? []
                              : [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                    ),
                    child: Icon(
                      item.icon,
                      color:
                          isDark
                              ? AppColors.darkPrimaryColor
                              : AppColors.primaryColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
                        color:
                            isDark
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
                          isHistoryExpanded.value = !isHistoryExpanded.value;
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color:
                                isHistoryExpanded.value
                                    ? AppColors.primaryColor.withValues(
                                      alpha: 0.3,
                                    )
                                    : isDark
                                    ? AppColors.darkPrimaryColor.withValues(
                                      alpha: 0.25,
                                    )
                                    : AppColors.primaryColor.withValues(
                                      alpha: 0.2,
                                    ),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.4,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            isHistoryExpanded.value
                                ? Icons.expand_less_rounded
                                : Icons.history_rounded,
                            size: 14.sp,
                            color:
                                isDark
                                    ? AppColors.darkPrimaryColor
                                    : AppColors.primaryColor,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(width: 5.w),
                  if (!_isViewer)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showDeleteCustomDataConfirmDialog(
                            itemIndex,
                            item.label,
                          );
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red[500],
                            size: 18.sp,
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
              color:
                  isDark
                      ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.15),
            ),
            if (lastEntry != null && !isHistoryExpanded.value)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                AppColors.darkSurfaceElevatedColor,
                                AppColors.darkSurfaceElevatedColor.withValues(
                                  alpha: 0.8,
                                ),
                              ]
                              : [
                                AppColors.primaryColor.withValues(alpha: 0.08),
                                AppColors.primaryColor.withValues(alpha: 0.04),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          isDark
                              ? AppColors.darkOutlineColor.withValues(
                                alpha: 0.3,
                              )
                              : AppColors.primaryColor.withValues(alpha: 0.2),
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
                              AppColors.primaryColor.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.3,
                              ),
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
                            Text(
                              lastEntry.text,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                color:
                                    isDark
                                        ? AppColors.darkPrimaryColor
                                        : AppColors.primaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 9.sp,
                                  color:
                                      isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[500],
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(lastEntry.date),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color:
                                        isDark
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
                              final entryIndex = item.entries.indexWhere(
                                (e) => e.id == lastEntry.id,
                              );
                              if (entryIndex != -1) {
                                _showDeleteCustomEntryConfirmDialog(
                                  itemIndex,
                                  entryIndex,
                                  lastEntry.text,
                                  item.label,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
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
            if (isHistoryExpanded.value && entries.isNotEmpty) ...[
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
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                AppColors.darkSurfaceElevatedColor,
                                AppColors.darkSurfaceElevatedColor.withValues(
                                  alpha: 0.8,
                                ),
                              ]
                              : [
                                AppColors.primaryColor.withValues(alpha: 0.08),
                                AppColors.primaryColor.withValues(alpha: 0.04),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          isDark
                              ? AppColors.darkOutlineColor.withValues(
                                alpha: 0.3,
                              )
                              : AppColors.primaryColor.withValues(alpha: 0.2),
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
                              AppColors.primaryColor.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.3,
                              ),
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
                            Text(
                              entry.text,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                color:
                                    isDark
                                        ? AppColors.darkPrimaryColor
                                        : AppColors.primaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 9.sp,
                                  color:
                                      isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[500],
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  DateFormat('yyyy-MM-dd').format(entry.date),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color:
                                        isDark
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
                              final originalIndex = item.entries.indexWhere(
                                (e) => e.id == entry.id,
                              );
                              if (originalIndex != -1) {
                                _showDeleteCustomEntryConfirmDialog(
                                  itemIndex,
                                  originalIndex,
                                  entry.text,
                                  item.label,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                gradient:
                    isDark
                        ? null
                        : LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.primaryColor.withValues(alpha: 0.02),
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
                      controller: textController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'أدخل بيانات جديدة',
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        filled: true,
                        fillColor:
                            isDark
                                ? AppColors.darkSurfaceElevatedColor
                                : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color:
                                isDark
                                    ? AppColors.darkOutlineColor
                                    : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color:
                                isDark
                                    ? AppColors.darkOutlineColor
                                    : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color:
                                isDark
                                    ? AppColors.darkPrimaryColor
                                    : AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark
                                ? AppColors.darkPrimaryColor
                                : Colors.black87,
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          customDataCtrl.addEntry(itemIndex, value);
                          textController.clear();
                          focusNode.unfocus();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Material(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10.r),
                    elevation: 2,
                    shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
                    child: InkWell(
                      onTap: () {
                        final value = textController.text;
                        if (value.isNotEmpty) {
                          customDataCtrl.addEntry(itemIndex, value);
                          textController.clear();
                          focusNode.unfocus();
                        } else {
                          focusNode.requestFocus();
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
                              AppColors.primaryColor.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.3,
                              ),
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

  void _showDeleteCustomDataConfirmDialog(int index, String label) {
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
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: Text(
          'هل تريد حذف "$label"؟',
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
              customDataCtrl.removeCustomDataItem(index);
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

  void _showDeleteCustomEntryConfirmDialog(
    int itemIndex,
    int entryIndex,
    String entryText,
    String itemLabel,
  ) {
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
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: Text(
          'هل تريد حذف "$entryText" من "$itemLabel"؟',
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
              customDataCtrl.removeEntry(itemIndex, entryIndex);
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
