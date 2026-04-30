import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/strings/app_strings.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/services/excel/excel_export_service.dart';
import '../../../core/services/pdf/pdf_export_service.dart';
import '../../../data/data_source/static/chicken_data.dart';
import '../../../logic/controller/cycle_controller.dart';

class CloseoutReportScreen extends StatelessWidget {
  final Map<String, dynamic> cycleData;

  const CloseoutReportScreen({super.key, required this.cycleData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = _calculateCloseoutData(cycleData);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackGroundColor : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(data, isDark),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildVerdictCard(data, isDark),
                  SizedBox(height: 12.h),
                  _buildSectionTitle('معلومات الدورة', isDark),
                  _buildInfoGrid([
                    _InfoItem('اسم الدورة', data.name, Icons.label_outline),
                    _InfoItem('عمر الدورة', '${data.ageDays} يوم', Icons.calendar_today),
                    _InfoItem('السلالة', data.breed, Icons.category_outlined),
                    _InfoItem('نظام التربية', data.systemType, Icons.home_outlined),
                    _InfoItem('مساحة العنبر', '${data.space} م²', Icons.straighten),
                    _InfoItem('تاريخ البدء', data.startDate, Icons.date_range),
                  ], isDark),
                  SizedBox(height: 12.h),
                  _buildSectionTitle('أداء القطيع', isDark),
                  _buildKpiRow([
                    _KpiItem('العدد الأولي', '${data.chickCount}', Icons.pets),
                    _KpiItem('النافق', '${data.mortality} (${data.mortalityRate}%)', Icons.warning_amber),
                    _KpiItem('الباقي', '${data.liveCount}', Icons.check_circle_outline),
                    _KpiItem('م. الوزن', '${data.avgWeight.toStringAsFixed(2)} كجم', Icons.monitor_weight_outlined),
                  ], isDark),
                  SizedBox(height: 12.h),
                  _buildSectionTitle('مؤشرات الأداء', isDark),
                  _buildKpiRow([
                    _KpiItem('FCR', data.fcr.toStringAsFixed(2), Icons.restaurant),
                    _KpiItem('EPEF', data.epef.toStringAsFixed(0), Icons.speed),
                    _KpiItem('تكلفة الفرخ', '${data.costPerBird.toStringAsFixed(1)} ج', Icons.attach_money),
                    _KpiItem('إجمالي العلف', '${data.totalFeed.toStringAsFixed(0)} كجم', Icons.grain),
                  ], isDark),
                  _buildBenchmarkRow(data, isDark),
                  SizedBox(height: 12.h),
                  _buildSectionTitle('المالية', isDark),
                  _buildFinancialSummary(data, isDark),
                  SizedBox(height: 12.h),
                  _buildSectionTitle('تصدير التقرير', isDark),
                  _buildExportButtons(cycleData, isDark),
                  SizedBox(height: 24.h),
                  _buildEndCycleButton(isDark),
                  SizedBox(height: 20.h),
                ]),
              ),
            ),
          ],
        ),
      );
  }

  void _proceedToEndCycle() {
    try {
      final controller = Get.find<CycleController>();
      unawaited(controller.endCurrentCycle());
    } catch (_) {}

    Get.back<void>();

    Future.delayed(const Duration(milliseconds: 600), () {
      try {
        final controller = Get.find<CycleController>();
        if (controller.cycles.isEmpty) {
          Get.back<void>();
        }
      } catch (_) {}
    });
  }

  Widget _buildHeader(_CloseoutData data, bool isDark) {
    return SliverToBoxAdapter(
      child: Container(
        height: 160.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkSurfaceElevatedColor, AppColors.darkBackGroundColor]
                : [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'تقرير ختامي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.summarize_outlined, color: Colors.white, size: 24.sp),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  data.name,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${data.ageDays} يوم — ${data.breed} — ${data.systemType}',
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                 ),
               ],
             ),
           ),
         ),
       ),
     );
   }

  Widget _buildVerdictCard(_CloseoutData data, bool isDark) {
    final isProfit = data.netProfit >= 0;
    final color = isProfit ? Colors.green : Colors.red;
    final icon = isProfit ? Icons.trending_up : Icons.trending_down;
    final label = isProfit ? 'ربح صافي' : 'خسارة صافية';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.2 : 0.1),
            color.withValues(alpha: isDark ? 0.05 : 0.02),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40.sp),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${isProfit ? '+' : ''}${data.netProfit.toStringAsFixed(0)} ج.م',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: isDark ? AppColors.darkOutlineColor : Colors.grey[300],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: isDark ? AppColors.darkOutlineColor : Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(List<_InfoItem> items, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.darkOutlineColor : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: items
            .map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 18.sp, color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor),
                      SizedBox(width: 8.w),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildKpiRow(List<_KpiItem> items, bool isDark) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceColor : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? AppColors.darkOutlineColor : Colors.grey[200]!,
              ),
            ),
            child: Column(
              children: [
                Icon(item.icon, size: 20.sp, color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor),
                SizedBox(height: 6.h),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                FittedBox(
                  child: Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBenchmarkRow(_CloseoutData data, bool isDark) {
    if (data.expectedWeight <= 0) return const SizedBox.shrink();

    final diff = data.avgWeight - data.expectedWeight;
    final isAbove = diff >= 0;
    final pctDiff = data.expectedWeight > 0 ? (diff / data.expectedWeight * 100) : 0.0;

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: (isAbove ? Colors.green : Colors.orange).withValues(alpha: isDark ? 0.1 : 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: (isAbove ? Colors.green : Colors.orange).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isAbove ? Icons.thumb_up_outlined : Icons.thumb_down_outlined,
              color: isAbove ? Colors.green : Colors.orange,
              size: 22.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مقارنة بالقياسي',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'الفعلي: ${_fmtWeight(data.avgWeight)} | القياسي: ${_fmtWeight(data.expectedWeight)} (${isAbove ? '+' : ''}${pctDiff.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
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

  Widget _buildFinancialSummary(_CloseoutData data, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.darkOutlineColor : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          _finRow('إجمالي المصروفات', '${data.totalExpenses.toStringAsFixed(0)} ج.م', isDark),
          _finRow('إجمالي المبيعات', '${data.totalSales.toStringAsFixed(0)} ج.م', isDark),
          _finRow('إجمالي اللحم المنتج', '${data.totalMeat.toStringAsFixed(0)} كجم', isDark),
          Divider(color: isDark ? AppColors.darkOutlineColor : Colors.grey[300]),
          _finRow(
            'صافي الربح / الخسارة',
            '${data.netProfit >= 0 ? '+' : ''}${data.netProfit.toStringAsFixed(0)} ج.م',
            isDark,
            valueColor: data.netProfit >= 0 ? Colors.green : Colors.red,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _finRow(String label, String value, bool isDark, {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons(Map<String, dynamic> cycle, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              try {
                await PdfExportService.exportCycleReport(cycle);
              } catch (e) {
                Get.snackbar(AppStrings.error, 'فشل تصدير PDF', backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            icon: Icon(Icons.picture_as_pdf_outlined, size: 18.sp),
            label: Text('PDF', style: TextStyle(fontSize: 13.sp)),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
              side: BorderSide(color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              try {
                await ExcelExportService.exportCycleReport(cycle);
              } catch (e) {
                Get.snackbar(AppStrings.error, 'فشل تصدير Excel', backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            icon: Icon(Icons.table_chart_outlined, size: 18.sp),
            label: Text('Excel', style: TextStyle(fontSize: 13.sp)),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
              side: BorderSide(color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndCycleButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _proceedToEndCycle();
          Get.back<void>();
        },
        icon: Icon(Icons.check_circle_outline, size: 22.sp),
        label: Text(
          'إنهاء الدورة',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
      ),
    );
  }

  String _fmtWeight(double kg) {
    if (kg < 1.0) return '${(kg * 1000).round()} جم';
    return '${kg.toStringAsFixed(2)} كجم';
  }

  _CloseoutData _calculateCloseoutData(Map<String, dynamic> cycle) {
    final name = cycle['name']?.toString() ?? 'دورة بدون اسم';
    final breed = cycle['breed']?.toString() ?? 'تسمين';
    final systemType = cycle['systemType']?.toString() ?? 'أرضي';
    final startDate = cycle['startDate']?.toString() ?? '-';
    final space = cycle['space']?.toString() ?? '0';
    final ageDays = int.tryParse(cycle['cycle_age']?.toString() ?? '0') ?? 0;

    final chickCount = int.tryParse(
          cycle['chickCount']?.toString() ?? cycle['chick_count']?.toString() ?? '0',
        ) ??
        0;
    final mortality = int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
    final mortalityRate = double.tryParse(cycle['mortality_rate']?.toString() ?? '0') ?? 0.0;
    final liveCount = chickCount - mortality;

    final avgWeight = double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
    final totalMeat = liveCount * avgWeight;
    final totalFeed = double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;
    final totalExpenses = double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
    final totalSales = double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
    final netProfit = double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;
    final costPerBird = liveCount > 0 ? totalExpenses / liveCount : 0.0;

    final fcr = (avgWeight > 0 && liveCount > 0) ? totalFeed / (liveCount * avgWeight) : 0.0;

    final survivalRate = chickCount > 0 ? (liveCount / chickCount) * 100 : 0.0;
    final epef = (ageDays > 0 && fcr > 0) ? (avgWeight * survivalRate) / (ageDays * fcr) * 100 : 0.0;

    double expectedWeight = 0.0;
    if (ageDays > 0 && ageDays <= weightsList.length) {
      expectedWeight = weightsList[ageDays - 1] / 1000.0;
    }

    return _CloseoutData(
      name: name,
      breed: breed,
      systemType: systemType,
      startDate: startDate,
      space: space,
      ageDays: ageDays,
      chickCount: chickCount,
      mortality: mortality,
      mortalityRate: mortalityRate,
      liveCount: liveCount,
      avgWeight: avgWeight,
      totalMeat: totalMeat,
      totalFeed: totalFeed,
      fcr: fcr,
      epef: epef,
      costPerBird: costPerBird,
      expectedWeight: expectedWeight,
      totalExpenses: totalExpenses,
      totalSales: totalSales,
      netProfit: netProfit,
    );
  }
}

class _CloseoutData {
  final String name;
  final String breed;
  final String systemType;
  final String startDate;
  final String space;
  final int ageDays;
  final int chickCount;
  final int mortality;
  final double mortalityRate;
  final int liveCount;
  final double avgWeight;
  final double totalMeat;
  final double totalFeed;
  final double fcr;
  final double epef;
  final double costPerBird;
  final double expectedWeight;
  final double totalExpenses;
  final double totalSales;
  final double netProfit;

  _CloseoutData({
    required this.name,
    required this.breed,
    required this.systemType,
    required this.startDate,
    required this.space,
    required this.ageDays,
    required this.chickCount,
    required this.mortality,
    required this.mortalityRate,
    required this.liveCount,
    required this.avgWeight,
    required this.totalMeat,
    required this.totalFeed,
    required this.fcr,
    required this.epef,
    required this.costPerBird,
    required this.expectedWeight,
    required this.totalExpenses,
    required this.totalSales,
    required this.netProfit,
  });
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  _InfoItem(this.label, this.value, this.icon);
}

class _KpiItem {
  final String label;
  final String value;
  final IconData icon;
  _KpiItem(this.label, this.value, this.icon);
}
