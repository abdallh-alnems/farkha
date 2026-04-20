import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';

class CycleComparisonScreen extends StatefulWidget {
  const CycleComparisonScreen({super.key});

  @override
  State<CycleComparisonScreen> createState() => _CycleComparisonScreenState();
}

class _CycleComparisonScreenState extends State<CycleComparisonScreen> {
  late final CycleController cycleCtrl;
  final RxList<Map<String, dynamic>> _selectedCycles =
      <Map<String, dynamic>>[].obs;
  final RxBool _showResults = false.obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    cycleCtrl =
        Get.isRegistered<CycleController>()
            ? Get.find<CycleController>()
            : Get.put(CycleController());
    _loadData();
  }

  Future<void> _loadData() async {
    if (cycleCtrl.historyCycles.isEmpty) {
      await cycleCtrl.fetchHistory(isRefresh: true);
    }
    if (mounted) _isLoading.value = false;
  }

  List<Map<String, dynamic>> get _allCycles {
    return cycleCtrl.historyCycles.toList();
  }

  void _toggleSelection(Map<String, dynamic> cycle) {
    final id = cycle['cycle_id']?.toString();
    final idx = _selectedCycles.indexWhere(
      (c) => c['cycle_id']?.toString() == id,
    );
    if (idx >= 0) {
      _selectedCycles.removeAt(idx);
    } else if (_selectedCycles.length < 3) {
      _selectedCycles.add(Map<String, dynamic>.from(cycle));
    } else {
      Get.snackbar(
        'حد أقصى',
        'يمكنك مقارنة 3 دورات كحد أقصى',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
        margin: EdgeInsets.all(16.r),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مقارنة الدورات',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor:
            isDark
                ? AppColors.darkBackGroundColor
                : AppColors.appBackGroundColor,
        elevation: 0,
        actions: [
          Obx(() {
            if (_selectedCycles.length >= 2 && !_showResults.value) {
              return Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: TextButton(
                  onPressed: () {
                    _showResults.value = true;
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'مقارنة (${_selectedCycles.length})',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_showResults.value) {
          return _buildComparisonResults(isDark);
        }
        return _buildCycleSelection(isDark);
      }),
    );
  }

  Widget _buildCycleSelection(bool isDark) {
    final allCycles = _allCycles;
    final selectedLen = _selectedCycles.length;

    if (allCycles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 64.sp,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد دورات للمقارنة',
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16.sp,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'اختر دورتين أو ثلاث للمقارنة',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$selectedLen/3',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: allCycles.length,
            itemBuilder: (context, index) {
              final cycle = allCycles[index];
              final id = cycle['cycle_id']?.toString();
              final isSelected =
                  _selectedCycles.any((c) => c['cycle_id']?.toString() == id);

              return _buildCycleCard(cycle, isSelected, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCycleCard(
    Map<String, dynamic> cycle,
    bool isSelected,
    bool isDark,
  ) {
    final name = cycle['name']?.toString() ?? 'دورة بدون اسم';
    final chickCount = cycle['chickCount']?.toString() ?? '0';
    final breed = cycle['breed']?.toString() ?? '';
    final systemType = cycle['systemType']?.toString() ?? 'أرضي';
    final cycleAge = cycle['cycle_age']?.toString() ?? '0';
    final startDate = cycle['startDate']?.toString() ?? '-';
    final endDate = cycle['endDate']?.toString() ?? '-';

    return GestureDetector(
      onTap: () => _toggleSelection(cycle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? _selectionColor.withValues(alpha: isDark ? 0.2 : 0.08)
                  : (isDark ? AppColors.darkSurfaceColor : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isSelected
                    ? _selectionColor
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _selectionColor : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected
                          ? _selectionColor
                          : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, size: 15.sp, color: Colors.white)
                      : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      _chip('$chickCount طائر', isDark),
                      if (breed.isNotEmpty) _chip(breed, isDark),
                      _chip(systemType, isDark),
                      _chip('$cycleAge يوم', isDark),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$startDate  -  $endDate',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, bool isDark) {
    return Container(
      margin: EdgeInsets.only(left: 6.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildComparisonResults(bool isDark) {
    final cycles = _selectedCycles.toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      child: Column(
        children: [
          _buildComparisonHeader(cycles, isDark),
          SizedBox(height: 16.h),
          _buildComparisonSection(
            title: 'معلومات الدورة',
            icon: Icons.info_outline_rounded,
            metrics: [
              _MetricRow('العدد الأولي', 'chickCount', 'طائر', isCount: true),
              _MetricRow('النافق', 'mortality', '', isCount: true),
              _MetricRow('نسبة النفوق', 'mortality_rate', '%'),
              _MetricRow('مدة الدورة', 'cycle_age', 'يوم', isCount: true),
              _MetricRow('السلالة', 'breed', '', isText: true),
              _MetricRow('نظام التربية', 'systemType', '', isText: true),
            ],
            cycles: cycles,
            isDark: isDark,
          ),
          SizedBox(height: 14.h),
          _buildComparisonSection(
            title: 'الأداء الإنتاجي',
            icon: Icons.bar_chart_rounded,
            metrics: [
              _MetricRow('متوسط الوزن', 'average_weight', 'كجم'),
              _MetricRow('معامل التحويل', 'fcr', ''),
              _MetricRow('تكلفة الفرخ', 'cost_per_bird', 'ج'),
              _MetricRow('إجمالي العلف', 'total_feed', 'كجم'),
            ],
            cycles: cycles,
            isDark: isDark,
          ),
          SizedBox(height: 14.h),
          _buildComparisonSection(
            title: 'المالية',
            icon: Icons.account_balance_wallet_rounded,
            metrics: [
              _MetricRow('المصروفات', 'total_expenses', 'ج'),
              _MetricRow('المبيعات', 'total_sales', 'ج'),
              _MetricRow('صافي الربح', 'net_profit', 'ج'),
            ],
            cycles: cycles,
            isDark: isDark,
          ),
                SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildComparisonHeader(
    List<Map<String, dynamic>> cycles,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 90.w),
          ...cycles.asMap().entries.map((entry) {
            final i = entry.key;
            final name = entry.value['name']?.toString() ?? '-';
            final color = _cycleColors[i % _cycleColors.length];
            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildComparisonSection({
    required String title,
    required IconData icon,
    required List<_MetricRow> metrics,
    required List<Map<String, dynamic>> cycles,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 6.h),
            child: Row(
              children: [
                Icon(icon, size: 17.sp, color: AppColors.primaryColor),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...metrics.map((m) => _buildMetricRow(m, cycles, isDark)),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    _MetricRow metric,
    List<Map<String, dynamic>> cycles,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              metric.label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ...cycles.map((cycle) {

            String display;
            if (metric.isText) {
              display = cycle[metric.key]?.toString() ?? '-';
            } else {
              final val =
                  double.tryParse(cycle[metric.key]?.toString() ?? '0') ?? 0.0;
              if (metric.isCount) {
                display = val.toInt().toString();
              } else if (val == val.truncateToDouble()) {
                display = val.toInt().toString();
              } else {
                display = val.toStringAsFixed(1);
              }
              if (metric.unit.isNotEmpty) display = '$display ${metric.unit}';
            }

            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  display,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static const Color _selectionColor = Color(0xFF1976D2);

  static const List<Color> _cycleColors = [
    Color(0xFF1976D2),
    Color(0xFFE65100),
    Color(0xFF7B1FA2),
  ];
}

class _MetricRow {
  final String label;
  final String key;
  final String unit;
  final bool isText;
  final bool isCount;

  _MetricRow(
    this.label,
    this.key,
    this.unit, {
    this.isText = false,
    this.isCount = false,
  });
}
