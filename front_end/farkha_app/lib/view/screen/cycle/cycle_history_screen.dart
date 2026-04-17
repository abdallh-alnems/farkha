import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';

class CycleHistoryScreen extends StatefulWidget {
  const CycleHistoryScreen({super.key});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen> {
  late final CycleController cycleCtrl;
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    cycleCtrl =
        Get.isRegistered<CycleController>()
            ? Get.find<CycleController>()
            : Get.put(CycleController());
    if (cycleCtrl.searchQuery.value.isNotEmpty) {
      _searchController.text = cycleCtrl.searchQuery.value;
    }
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await cycleCtrl.fetchHistory(isRefresh: true);
    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سجل الدورات',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor:
            isDark
                ? AppColors.darkBackGroundColor
                : AppColors.appBackGroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTopControls(isDark, context),
          Expanded(
            child:
                _isInitialLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: AppColors.primaryColor,
                        child: Obx(() {
                          if (cycleCtrl.historyCycles.isEmpty) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 150.h),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        cycleCtrl.searchQuery.value.isNotEmpty
                                            ? Icons.search_off
                                            : Icons.history,
                                        size: 64.sp,
                                        color:
                                            isDark
                                                ? Colors.grey[700]
                                                : Colors.grey[300],
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        cycleCtrl.searchQuery.value.isNotEmpty
                                            ? 'لا توجد نتائج تطابق بحثك'
                                            : 'لا يوجد سجل دورات سابقة',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color:
                                              isDark
                                                  ? Colors.grey[500]
                                                  : Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: cycleCtrl.historyScrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(16.r),
                            itemCount:
                                cycleCtrl.historyCycles.length +
                                (cycleCtrl.isLoadingMore.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == cycleCtrl.historyCycles.length) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0.r),
                                    child: const CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final cycle = cycleCtrl.historyCycles[index];
                              return _buildHistoryCard(context, cycle, isDark);
                            },
                          );
                        }),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          cycleCtrl.searchHistory(value);
        },
        decoration: InputDecoration(
          hintText: 'ابحث بإسم الدورة...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[400],
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[500],
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () {
                      _searchController.clear();
                      cycleCtrl.searchHistory('');
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls(bool isDark, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSearchBar(isDark)),
            GestureDetector(
              onTap: () async {
                final initialDateRange =
                    cycleCtrl.filterDateFrom.value.isNotEmpty &&
                            cycleCtrl.filterDateTo.value.isNotEmpty
                        ? DateTimeRange(
                          start: DateTime.parse(cycleCtrl.filterDateFrom.value),
                          end: DateTime.parse(cycleCtrl.filterDateTo.value),
                        )
                        : null;

                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDateRange: initialDateRange,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme:
                            isDark
                                ? const ColorScheme.dark(
                                  primary: AppColors.primaryColor,
                                )
                                : const ColorScheme.light(
                                  primary: AppColors.primaryColor,
                                ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  final DateFormat formatter = DateFormat('yyyy-MM-dd');
                  cycleCtrl.setDateFilter(
                    formatter.format(picked.start),
                    formatter.format(picked.end),
                  );
                }
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(16.w, 16.h, 0, 0),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color:
                      cycleCtrl.filterDateFrom.value.isNotEmpty
                          ? AppColors.primaryColor.withOpacity(0.2)
                          : (isDark
                              ? AppColors.darkSurfaceColor
                              : Colors.white),
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      cycleCtrl.filterDateFrom.value.isNotEmpty
                          ? Border.all(color: AppColors.primaryColor)
                          : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.date_range,
                  color:
                      cycleCtrl.filterDateFrom.value.isNotEmpty
                          ? AppColors.primaryColor
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          if (cycleCtrl.filterDateFrom.value.isNotEmpty &&
              cycleCtrl.filterDateTo.value.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'من ${cycleCtrl.filterDateFrom.value} إلى ${cycleCtrl.filterDateTo.value}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => cycleCtrl.clearDateFilter(),
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    Map<String, dynamic> cycle,
    bool isDark,
  ) {
    final name = cycle['name']?.toString() ?? 'دورة بدون اسم';
    final startDate = cycle['startDate']?.toString() ?? '-';
    final endDate = cycle['endDate']?.toString() ?? '-';

    // الأرقام والمقاييس
    final chickCount = cycle['chickCount']?.toString() ?? '0';
    final liveCount =
        (int.tryParse(chickCount) ?? 0) -
        (int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0);
    final mortality = cycle['mortality']?.toString() ?? '0';

    final systemType = cycle['systemType']?.toString() ?? 'أرضي';
    final breed = cycle['breed']?.toString() ?? 'تسمين';
    final fcr = cycle['fcr']?.toString() ?? '0.00';
    final costPerBird = cycle['cost_per_bird']?.toString() ?? '0.00';
    final cycleAge = cycle['cycle_age']?.toString() ?? '0';
    final totalExpenses =
        double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
    final totalSales =
        double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
    final netProfit =
        double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;
    final totalFeed =
        double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;
    final averageWeight =
        double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
    final mortalityRate = cycle['mortality_rate']?.toString() ?? '0.0';

    return InkWell(
      onTap: () {
        cycleCtrl.historicCycleDetails.assignAll(cycle);
        final cycleId = int.tryParse(cycle['cycle_id']?.toString() ?? '0') ?? 0;
        if (cycleId > 0) {
          cycleCtrl.fetchHistoricCycleDetails(cycleId);
        }
        Get.toNamed<void>(AppRoute.cycleHistoryDetails);
      },
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Column(
          children: [
            // ========================= Header =========================
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppColors.darkSurfaceElevatedColor
                        : Colors.grey[50]?.withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      if (breed.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: 6.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            breed,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sunsetGradientEnd.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: AppColors.sunsetGradientEnd.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          systemType,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.sunsetGradientEnd,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 20.sp,
                        ),
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'share') {
                            _shareCycle(cycle);
                          } else if (value == 'delete') {
                            Get.snackbar(
                              'قريباً',
                              'ميزة إزالة السجل نهائياً ستكون متاحة قريباً',
                              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                              colorText: isDark ? Colors.white : Colors.black,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share_outlined, color: Colors.blueAccent, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text('مشاركة', style: TextStyle(fontSize: 14.sp)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.redAccent, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text('حذف من السجل', style: TextStyle(fontSize: 14.sp)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ========================= Dates & Age =========================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '$startDate  -  $endDate',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$cycleAge يوم',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ========================= Main Metrics Grid =========================
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: Column(
                children: [
                  // العدد الأولي + المتبقي في كارد واحد
                  _buildChickCountCard(
                    isDark: isDark,
                    initialCount: chickCount,
                    liveCount: liveCount.toString(),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPremiumMetricBox(
                          isDark: isDark,
                          label: 'النافق',
                          value: '$mortality ($mortalityRate%)',
                          accentColor: const Color(0xFFF43F5E),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildPremiumMetricBox(
                          isDark: isDark,
                          label: 'تكلفة الفرخ',
                          value: costPerBird,
                          accentColor: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPremiumMetricBox(
                          isDark: isDark,
                          label: 'معامل التحويل',
                          value: fcr,
                          accentColor: const Color(0xFF6366F1),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildPremiumMetricBox(
                          isDark: isDark,
                          label: 'متوسط الوزن',
                          value: '${averageWeight.toStringAsFixed(1)} كجم',
                          accentColor: const Color(0xFF9333EA),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ========================= Footer Stats =========================
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : const Color(0xFFF8FAFC),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _buildFooterStat(
                      label: 'العلف',
                      value: totalFeed.toStringAsFixed(0),
                      unit: 'كجم',
                      isDark: isDark,
                    ),
                    _buildFooterDivider(isDark),
                    _buildFooterStat(
                      label: 'المصروفات',
                      value: totalExpenses.toStringAsFixed(0),
                      unit: 'ج',
                      isDark: isDark,
                    ),
                    _buildFooterDivider(isDark),
                    _buildFooterStat(
                      label: 'المبيعات',
                      value: totalSales.toStringAsFixed(0),
                      unit: 'ج',
                      isDark: isDark,
                    ),
                    _buildFooterDivider(isDark),
                    _buildFooterStat(
                      label: 'الصافي',
                      value: netProfit.toStringAsFixed(0),
                      unit: 'ج',
                      isDark: isDark,
                      valueColor: netProfit >= 0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildFooterStat({
    required String label,
    required String value,
    required String unit,
    required bool isDark,
    Color? valueColor,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30.h,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  /// كارد مدمج يعرض العدد الأولي والمتبقي معاً
  Widget _buildChickCountCard({
    required bool isDark,
    required String initialCount,
    required String liveCount,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevatedColor : Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  initialCount,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'العدد الأولي',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  liveCount,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10B981),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'المتبقي',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareCycle(Map<String, dynamic> cycle) {
    final name = cycle['name']?.toString() ?? 'دورة بدون اسم';
    final startDate = cycle['startDate']?.toString() ?? '-';
    final endDate = cycle['endDate']?.toString() ?? '-';
    final breed = cycle['breed']?.toString() ?? '-';
    final systemType = cycle['systemType']?.toString() ?? 'أرضي';
    final chickCount = int.tryParse(cycle['chickCount']?.toString() ?? '0') ?? 0;
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final mortalityRate = cycle['mortality_rate']?.toString() ?? '0.0';
    final cycleAge = cycle['cycle_age']?.toString() ?? '0';
    final fcr = cycle['fcr']?.toString() ?? '0.0';
    final costPerBird = cycle['cost_per_bird']?.toString() ?? '0.00';
    final averageWeight = double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
    final totalFeed = double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;
    final totalExpenses = double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
    final totalSales = double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
    final netProfit = double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;
    final liveCount = chickCount - mortality;

    final text = '''
🐔 ملخص دورة: $name
━━━━━━━━━━━━━━━━━━━━
📋 معلومات الدورة
📅 من: $startDate
📅 إلى: $endDate
⏳ مدة الدورة: $cycleAge يوم
🌾 السلالة: $breed
🏠 نظام التربية: $systemType

━━━━━━━━━━━━━━━━━━━━
🐣 الطيور
   العدد الأولي: $chickCount طير
   المتبقي:      $liveCount طير
   النافق:       $mortality ($mortalityRate%)

━━━━━━━━━━━━━━━━━━━━
📊 الأداء الإنتاجي
   متوسط الوزن:    ${averageWeight.toStringAsFixed(2)} كجم
   معامل التحويل:  $fcr
   تكلفة الفرخ:   $costPerBird ج
   إجمالي العلف:  ${totalFeed.toStringAsFixed(0)} كجم

━━━━━━━━━━━━━━━━━━━━
💰 المالية
   المصروفات: ${totalExpenses.toStringAsFixed(0)} ج
   المبيعات:  ${totalSales.toStringAsFixed(0)} ج
   الصافي:    ${netProfit >= 0 ? '+' : ''}${netProfit.toStringAsFixed(0)} ج
''';

    SharePlus.instance.share(ShareParams(text: text, subject: 'ملخص دورة: $name'));
  }

  /// مربع إحصائية بدون أيقونة
  Widget _buildPremiumMetricBox({
    required bool isDark,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevatedColor : Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Container(
                width: 3.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
