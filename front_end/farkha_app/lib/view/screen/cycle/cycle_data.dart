import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../data/data_source/static/vaccination_data.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_custom_data_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';

class CycleDataScreen extends StatefulWidget {
  const CycleDataScreen({super.key});

  @override
  State<CycleDataScreen> createState() => _CycleDataScreenState();
}

class _CycleDataScreenState extends State<CycleDataScreen> {
  final cycleCtrl = Get.find<CycleController>();
  final customDataCtrl = Get.put(CycleCustomDataController(), permanent: true);
  final broilerCtrl = Get.find<BroilerController>();
  late final TextEditingController _mortalityNewController;
  late final TextEditingController _averageWeightController;
  late final TextEditingController _medicationController;
  late final TextEditingController _feedConsumptionController;

  // تتبع التحصينات المضافة لإخفائها من القائمة
  final RxSet<String> _addedVaccinations = <String>{}.obs;
  final RxBool _isManualVaccinationEntry = false.obs;

  int get _currentMortalityTotal {
    final cycle = cycleCtrl.currentCycle;
    return int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
  }

  String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.round().toString();
    }
    return weight.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  void initState() {
    super.initState();
    _mortalityNewController = TextEditingController();
    _averageWeightController = TextEditingController();
    _medicationController = TextEditingController();
    _feedConsumptionController = TextEditingController();

    // تحميل التحصينات المضافة مسبقاً
    _loadAddedVaccinations();
  }

  void _loadAddedVaccinations() {
    final entries = cycleCtrl.getMedicationEntries();
    final allVaccinationNames =
        VaccinationData.vaccinationSchedule.map((v) => v.vaccineName).toSet();

    for (var entry in entries) {
      if (allVaccinationNames.contains(entry.text)) {
        _addedVaccinations.add(entry.text);
      }
    }
  }

  @override
  void dispose() {
    _mortalityNewController.dispose();
    _averageWeightController.dispose();
    _medicationController.dispose();
    _feedConsumptionController.dispose();
    super.dispose();
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
          onPressed: () => Get.back(),
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
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? AppColors.darkPrimaryColor : Colors.white,
            ),
            onPressed: () => _showAddDataDialog(isDark),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMortalityInputCard(isDark),
              SizedBox(height: 20.h),
              _buildAverageWeightInputCard(isDark),
              SizedBox(height: 20.h),
              const AdNativeWidget(),
              SizedBox(height: 20.h),
              _buildMedicationInputCard(isDark),
              SizedBox(height: 20.h),
              _buildFeedConsumptionInputCard(isDark),
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
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildMortalityInputCard(bool isDark) {
    final isHistoryExpanded = false.obs;

    return Obx(() {
      final cycle = cycleCtrl.currentCycle;
      final entries = cycleCtrl.getMortalityEntries();
      final lastEntry = entries.isNotEmpty ? entries.last : null;
      final sortedEntries = List.from(entries)
        ..sort((a, b) => b.date.compareTo(a.date));
      final currentTotal = _currentMortalityTotal;
      final chickCount =
          int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
      final mortalityPercentage =
          chickCount > 0 ? (currentTotal / chickCount * 100) : 0.0;

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
            width: 1,
          ),
          boxShadow:
              isDark
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                  ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                isDark
                                    ? [
                                      AppColors.darkPrimaryColor.withValues(alpha: 
                                        0.2,
                                      ),
                                      AppColors.darkPrimaryColor.withValues(alpha: 
                                        0.15,
                                      ),
                                    ]
                                    : [
                                      AppColors.primaryColor.withValues(alpha: 0.15),
                                      AppColors.primaryColor.withValues(alpha: 0.08),
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
                                      color: AppColors.primaryColor.withValues(alpha: 
                                        0.1,
                                      ),
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                        ),
                        child: Icon(
                          Icons.cancel_outlined,
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
                          'عدد النافق',
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
                      if (currentTotal > 0)
                        Row(
                          children: [
                            Text(
                              '$currentTotal',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? AppColors.darkPrimaryColor
                                        : AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(${mortalityPercentage.round()}%)',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
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
                              isHistoryExpanded.value =
                                  !isHistoryExpanded.value;
                            },
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color:
                                    isHistoryExpanded.value
                                        ? AppColors.primaryColor.withValues(alpha: 
                                          0.3,
                                        )
                                        : isDark
                                        ? AppColors.darkPrimaryColor
                                            .withValues(alpha: 0.25)
                                        : AppColors.primaryColor.withValues(alpha: 
                                          0.2,
                                        ),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.primaryColor.withValues(alpha: 
                                    0.4,
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
                    ],
                  ),
                ],
              ),
            ),

            // Divider
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
                  margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                AppColors.darkSurfaceElevatedColor,
                                AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                                  0.8,
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
                              ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                                    color:
                                        isDark
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
                                    'فرخ',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDark
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showDeleteMortalityConfirmDialog(lastEntry);
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
                                AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                                  0.8,
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
                              ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                                    color:
                                        isDark
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
                                    'فرخ',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDark
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showDeleteMortalityConfirmDialog(entry);
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

            // Input Section
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
                      controller: _mortalityNewController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'أدخل العدد',
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
                        suffixText: 'فرخ',
                        suffixStyle: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                        final value = _mortalityNewController.text;
                        final count = int.tryParse(value) ?? 0;
                        if (count > 0) {
                          _saveMortality();
                        } else {
                          _mortalityNewController.clear();
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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

  Widget _buildAverageWeightInputCard(bool isDark) {
    final isHistoryExpanded = false.obs;

    return Obx(() {
      final entries = cycleCtrl.getAverageWeightEntries();
      final lastEntry = entries.isNotEmpty ? entries.last : null;
      final sortedEntries = List.from(entries)
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
            width: 1,
          ),
          boxShadow:
              isDark
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                  ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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
                                  AppColors.darkPrimaryColor.withValues(alpha: 0.2),
                                  AppColors.darkPrimaryColor.withValues(alpha: 0.15),
                                ]
                                : [
                                  AppColors.primaryColor.withValues(alpha: 0.15),
                                  AppColors.primaryColor.withValues(alpha: 0.08),
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
                                  color: AppColors.primaryColor.withValues(alpha: 
                                    0.1,
                                  ),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                    ),
                    child: Icon(
                      Icons.monitor_weight,
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
                      'متوسط وزن القطيع',
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
                                    ? AppColors.primaryColor.withValues(alpha: 0.3)
                                    : isDark
                                    ? AppColors.darkPrimaryColor.withValues(alpha: 
                                      0.25,
                                    )
                                    : AppColors.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.4),
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
                ],
              ),
            ),

            // Divider
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
                  margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                AppColors.darkSurfaceElevatedColor,
                                AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                                  0.8,
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
                              ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                                    color:
                                        isDark
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
                                      color:
                                          isDark
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showDeleteAverageWeightConfirmDialog(lastEntry);
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
                                AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                                  0.8,
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
                              ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                                  _formatWeight(entry.weight),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                    color:
                                        isDark
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
                                      color:
                                          isDark
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showDeleteAverageWeightConfirmDialog(entry);
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

            // Input Section
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
                      controller: _averageWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'أدخل متوسط وزن القطيع',
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
                        suffixText: 'كيلو',
                        suffixStyle: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                        final value = _averageWeightController.text;
                        final weight = double.tryParse(value) ?? 0.0;
                        if (weight > 0) {
                          _saveAverageWeight();
                        } else {
                          _averageWeightController.clear();
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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

  Widget _buildMedicationInputCard(bool isDark) {
    final isHistoryExpanded = false.obs;

    return Obx(() {
      final entries = cycleCtrl.getMedicationEntries();
      final lastEntry = entries.isNotEmpty ? entries.last : null;
      final sortedEntries = List.from(entries)
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
            width: 1,
          ),
          boxShadow:
              isDark
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                  ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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
                                  AppColors.darkPrimaryColor.withValues(alpha: 0.2),
                                  AppColors.darkPrimaryColor.withValues(alpha: 0.15),
                                ]
                                : [
                                  AppColors.primaryColor.withValues(alpha: 0.15),
                                  AppColors.primaryColor.withValues(alpha: 0.08),
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
                                  color: AppColors.primaryColor.withValues(alpha: 
                                    0.1,
                                  ),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                    ),
                    child: Icon(
                      Icons.medication,
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
                      'التحصينات',
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
                                    ? AppColors.primaryColor.withValues(alpha: 0.3)
                                    : isDark
                                    ? AppColors.darkPrimaryColor.withValues(alpha: 
                                      0.25,
                                    )
                                    : AppColors.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.4),
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
                ],
              ),
            ),

            // Divider
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
                  margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                AppColors.darkSurfaceElevatedColor,
                                AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                                  0.8,
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
                              ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showDeleteMedicationConfirmDialog(lastEntry);
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
                                AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                                  0.8,
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
                              ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showDeleteMedicationConfirmDialog(entry);
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

            // Input Section
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
              child: Obx(() {
                final allVaccinations = VaccinationData.vaccinationSchedule;
                final availableVaccinations =
                    allVaccinations
                        .where(
                          (v) => !_addedVaccinations.contains(v.vaccineName),
                        )
                        .toList();

                String? selectedVaccination;

                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppColors.darkSurfaceElevatedColor
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color:
                              isDark
                                  ? AppColors.darkOutlineColor
                                  : Colors.grey[300]!,
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: selectedVaccination,
                        isExpanded: true,
                        hint: Text(
                          'اختر تحصين من القائمة',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color:
                              isDark
                                  ? AppColors.darkPrimaryColor
                                  : AppColors.primaryColor,
                        ),
                        items: [
                          ...availableVaccinations.map((vaccination) {
                            return DropdownMenuItem<String>(
                              value: vaccination.vaccineName,
                              child: Text(
                                '${vaccination.vaccineName} (عمر ${vaccination.age} يوم)',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      isDark
                                          ? AppColors.darkPrimaryColor
                                          : Colors.black87,
                                ),
                              ),
                            );
                          }),
                          DropdownMenuItem<String>(
                            value: 'manual',
                            child: Text(
                              'تحصين آخر',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color:
                                    isDark
                                        ? AppColors.darkPrimaryColor
                                        : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == 'manual') {
                            _isManualVaccinationEntry.value = true;
                            _medicationController.clear();
                          } else if (value != null) {
                            // إضافة التحصين المختار تلقائياً
                            _addedVaccinations.add(value);
                            cycleCtrl.addMedicationEntry(value);
                            selectedVaccination = null;
                          }
                        },
                      ),
                    ),
                    if (_isManualVaccinationEntry.value) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _medicationController,
                              decoration: InputDecoration(
                                hintText: 'أدخل اسم التحصين',
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[400],
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
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Material(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10.r),
                            elevation: 2,
                            shadowColor: AppColors.primaryColor.withValues(alpha: 
                              0.3,
                            ),
                            child: InkWell(
                              onTap: () {
                                final value = _medicationController.text;
                                if (value.isNotEmpty) {
                                  _saveMedication();
                                  _isManualVaccinationEntry.value = false;
                                } else {
                                  _medicationController.clear();
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
                                      color: AppColors.primaryColor.withValues(alpha: 
                                        0.3,
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
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFeedConsumptionInputCard(bool isDark) {
    final isHistoryExpanded = false.obs;

    return Obx(() {
      final entries = cycleCtrl.getFeedConsumptionEntries();
      final lastEntry = entries.isNotEmpty ? entries.last : null;
      final sortedEntries = List.from(entries)
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
            width: 1,
          ),
          boxShadow:
              isDark
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                  ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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
                                  AppColors.darkPrimaryColor.withValues(alpha: 0.2),
                                  AppColors.darkPrimaryColor.withValues(alpha: 0.15),
                                ]
                                : [
                                  AppColors.primaryColor.withValues(alpha: 0.15),
                                  AppColors.primaryColor.withValues(alpha: 0.08),
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
                                  color: AppColors.primaryColor.withValues(alpha: 
                                    0.1,
                                  ),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                    ),
                    child: Icon(
                      Icons.grain,
                      color:
                          isDark
                              ? AppColors.darkPrimaryColor
                              : AppColors.primaryColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استهلاك العلف',
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
                        Builder(
                          builder: (context) {
                            final total = entries.fold<double>(
                              0.0,
                              (sum, entry) => sum + entry.amount,
                            );
                            if (total > 0) {
                              return Padding(
                                padding: EdgeInsets.only(top: 3.h),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isDark
                                                ? AppColors.darkPrimaryColor
                                                    .withValues(alpha: 0.2)
                                                : AppColors.primaryColor
                                                    .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                          5.r,
                                        ),
                                      ),
                                      child: Text(
                                        'المجموع: ${_formatWeight(total)} كيلو',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isDark
                                                  ? AppColors.darkPrimaryColor
                                                  : AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
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
                                    ? AppColors.primaryColor.withValues(alpha: 0.3)
                                    : isDark
                                    ? AppColors.darkPrimaryColor.withValues(alpha: 
                                      0.25,
                                    )
                                    : AppColors.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.4),
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
                ],
              ),
            ),

            // Divider
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
                  margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                AppColors.darkSurfaceElevatedColor,
                                AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                                  0.8,
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
                              ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                                  _formatWeight(lastEntry.amount),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                    color:
                                        isDark
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
                                      color:
                                          isDark
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showDeleteFeedConsumptionConfirmDialog(lastEntry);
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
                                AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                                  0.8,
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
                              ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                                  _formatWeight(entry.amount),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                    color:
                                        isDark
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
                                      color:
                                          isDark
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showDeleteFeedConsumptionConfirmDialog(entry);
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

            // Input Section
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
                      controller: _feedConsumptionController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'أدخل استهلاك العلف',
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
                        suffixText: 'كيلو',
                        suffixStyle: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                        final value = _feedConsumptionController.text;
                        final amount = double.tryParse(value) ?? 0.0;
                        if (amount > 0) {
                          _saveFeedConsumption();
                        } else {
                          _feedConsumptionController.clear();
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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

  Future<void> _saveMortality() async {
    final newMortalityText = _mortalityNewController.text.trim();
    if (newMortalityText.isEmpty) return;

    final newValue = int.tryParse(newMortalityText) ?? 0;
    if (newValue <= 0) return;

    await cycleCtrl.addMortalityEntry(newValue);

    _mortalityNewController.clear();
  }

  Future<void> _saveAverageWeight() async {
    final value = _averageWeightController.text.trim();
    if (value.isEmpty) return;

    final weight = double.tryParse(value) ?? 0.0;
    if (weight <= 0) return;

    await cycleCtrl.addAverageWeightEntry(weight);

    _averageWeightController.clear();
  }

  Future<void> _saveMedication() async {
    final value = _medicationController.text.trim();
    if (value.isEmpty) return;

    await cycleCtrl.addMedicationEntry(value);

    _medicationController.clear();
  }

  Future<void> _saveFeedConsumption() async {
    final value = _feedConsumptionController.text.trim();
    if (value.isEmpty) return;

    final amount = double.tryParse(value) ?? 0.0;
    if (amount <= 0) return;

    await cycleCtrl.addFeedConsumptionEntry(amount);

    _feedConsumptionController.clear();
  }

  void _showDeleteAverageWeightConfirmDialog(WeightEntry entry) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: Text(
          'هل تريد حذف ${_formatWeight(entry.weight)} كيلو من قسم متوسط وزن القطيع؟',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق الـ Dialog مباشرة
              cycleCtrl.removeAverageWeightEntry(entry.id); // تنفيذ الحذف في الخلفية
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showDeleteMedicationConfirmDialog(MedicationEntry entry) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: Text(
          'هل تريد حذف ${entry.text} من قسم التحصينات؟',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // إزالة التحصين من القائمة المضافة إذا كان من القائمة المحددة
              final allVaccinationNames =
                  VaccinationData.vaccinationSchedule
                      .map((v) => v.vaccineName)
                      .toSet();
              if (allVaccinationNames.contains(entry.text)) {
                _addedVaccinations.remove(entry.text);
              }

              Get.back(); // إغلاق الـ Dialog مباشرة
              cycleCtrl.removeMedicationEntry(entry.id); // تنفيذ الحذف في الخلفية
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFeedConsumptionConfirmDialog(FeedConsumptionEntry entry) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: Text(
          'هل تريد حذف ${_formatWeight(entry.amount)} كيلو من قسم استهلاك العلف؟',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق الـ Dialog مباشرة
              cycleCtrl.removeFeedConsumptionEntry(entry.id); // تنفيذ الحذف في الخلفية
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showDeleteMortalityConfirmDialog(MortalityEntry entry) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        content: Text(
          'هل تريد حذف ${entry.count} فرخ من قسم عدد النافق؟',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق الـ Dialog مباشرة
              cycleCtrl.removeMortalityEntry(entry.id); // تنفيذ الحذف في الخلفية
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddDataDialog(bool isDark) {
    final nameController = TextEditingController();
    const IconData defaultIcon = Icons.note;

    Get.dialog(
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
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
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
                Get.back();
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
      final sortedEntries = List.from(entries)
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
            width: 1,
          ),
          boxShadow:
              isDark
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
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
                                  AppColors.darkPrimaryColor.withValues(alpha: 0.2),
                                  AppColors.darkPrimaryColor.withValues(alpha: 0.15),
                                ]
                                : [
                                  AppColors.primaryColor.withValues(alpha: 0.15),
                                  AppColors.primaryColor.withValues(alpha: 0.08),
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
                                  color: AppColors.primaryColor.withValues(alpha: 
                                    0.1,
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
                                    ? AppColors.primaryColor.withValues(alpha: 0.3)
                                    : isDark
                                    ? AppColors.darkPrimaryColor.withValues(alpha: 
                                      0.25,
                                    )
                                    : AppColors.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.4),
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
                  margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                AppColors.darkSurfaceElevatedColor,
                                AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                                  0.8,
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
                              ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                                AppColors.darkSurfaceElevatedColor.withValues(alpha: 
                                  0.8,
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
                              ? AppColors.darkOutlineColor.withValues(alpha: 0.3)
                              : AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
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

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'تأكيد الحذف',
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
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق الـ Dialog مباشرة
              customDataCtrl.removeCustomDataItem(index); // تنفيذ الحذف في الخلفية
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('حذف'),
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

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'تأكيد الحذف',
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
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق الـ Dialog مباشرة
              customDataCtrl.removeEntry(itemIndex, entryIndex); // تنفيذ الحذف في الخلفية
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
