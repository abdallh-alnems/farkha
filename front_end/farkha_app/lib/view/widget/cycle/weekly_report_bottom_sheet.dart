import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import 'weekly_report_sections.dart';

class WeeklyReportBottomSheet extends StatefulWidget {
  final Map<String, dynamic> cycle;

  const WeeklyReportBottomSheet({super.key, required this.cycle});

  static Future<void> show(BuildContext context, Map<String, dynamic> cycle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackGroundColor : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: WeeklyReportBottomSheet(cycle: cycle),
          ),
        ),
      ),
    );
  }

  @override
  State<WeeklyReportBottomSheet> createState() => _WeeklyReportBottomSheetState();
}

class _WeeklyReportBottomSheetState extends State<WeeklyReportBottomSheet> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _ensureDataLoaded();
  }

  Future<void> _ensureDataLoaded() async {
    final cycleCtrl = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : null;

    if (cycleCtrl == null) {
      if (mounted) setState(() { _isLoading = false; });
      return;
    }

    final hasEntries = cycleCtrl.currentCycle['mortalityEntries'] != null
        || cycleCtrl.currentCycle['averageWeightEntries'] != null;

    final sameCycle = cycleCtrl.currentCycle['cycle_id'] != null
        && cycleCtrl.currentCycle['cycle_id'].toString() == widget.cycle['cycle_id']?.toString();

    if (hasEntries && sameCycle) {
      if (mounted) setState(() { _isLoading = false; });
      return;
    }

    cycleCtrl.currentCycle.assignAll(widget.cycle);

    final rawId = widget.cycle['cycle_id'];
    final cycleId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;

    if (cycleId <= 0) {
      if (mounted) setState(() { _isLoading = false; });
      return;
    }

    try {
      await cycleCtrl.fetchCycleDetails(cycleId, silent: true);
      if (mounted) setState(() { _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[isDark ? 600 : 400],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? _buildLoadingState(isDark)
              : _hasError
                  ? _buildErrorState(isDark)
                  : _buildReportContent(isDark),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor),
          SizedBox(height: 16.h),
          Text(
            'جارٍ تحميل بيانات الأسبوع...',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 40.sp, color: Colors.grey[isDark ? 600 : 400]),
          SizedBox(height: 12.h),
          Text(
            'تعذر تحميل البيانات',
            style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: () {
              setState(() { _isLoading = true; _hasError = false; });
              _ensureDataLoaded();
            },
            icon: Icon(Icons.refresh, size: 18.sp),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(bool isDark) {
    final data = _aggregateWeeklyData();
    final cycleName = widget.cycle['name']?.toString() ?? 'دورة';

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        WeeklyReportHeader(cycleName: cycleName, isDark: isDark),
        SizedBox(height: 16.h),
        if (data.daysWithData == 0)
          WeeklyReportEmptyState(isDark: isDark)
        else ...[
          WeeklyReportSectionTitle(title: 'القطيع', isDark: isDark),
          WeeklyReportKpiRow(items: [
            KpiItem('النفوق', '${data.mortality} طائر', Icons.warning_amber_rounded, data.mortality > 0 ? Colors.orange : null),
            KpiItem('م. الوزن', _fmtWeight(data.avgWeight), Icons.monitor_weight_outlined),
            KpiItem('أيام مسجلة', '${data.daysWithData}/7', Icons.edit_calendar_outlined),
          ], isDark: isDark),
          SizedBox(height: 14.h),
          WeeklyReportSectionTitle(title: 'التغذية', isDark: isDark),
          WeeklyReportKpiRow(items: [
            KpiItem('العلف', '${data.totalFeed.toStringAsFixed(1)} كجم', Icons.grain),
            if (data.totalWater > 0)
              KpiItem('المياه', '${data.totalWater.toStringAsFixed(1)} لتر', Icons.water_drop_outlined),
            if (data.fcr > 0)
              KpiItem('FCR', data.fcr.toStringAsFixed(2), Icons.restaurant),
          ], isDark: isDark),
          SizedBox(height: 14.h),
          WeeklyReportSectionTitle(title: 'المالية', isDark: isDark),
          WeeklyReportFinancialCard(data: data, isDark: isDark),
          SizedBox(height: 14.h),
          if (data.medications.isNotEmpty) ...[
            WeeklyReportSectionTitle(title: 'الأدوية والتطعيمات', isDark: isDark),
            WeeklyReportMedicationsList(data: data, isDark: isDark),
            SizedBox(height: 14.h),
          ],
        ],
        SizedBox(height: 24.h),
      ],
    );
  }

  String _fmtWeight(double kg) {
    if (kg <= 0) return '-';
    if (kg < 1.0) return '${(kg * 1000).round()} جم';
    return '${kg.toStringAsFixed(2)} كجم';
  }

  WeeklyData _aggregateWeeklyData() {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    int totalMortality = 0;
    double totalFeed = 0.0;
    double totalWater = 0.0;
    double totalWeightSum = 0.0;
    int weightCount = 0;
    double totalExpenses = 0.0;
    double totalSales = 0.0;
    final List<String> medications = [];
    final Set<String> uniqueDays = {};

    final cycleCtrl = Get.isRegistered<CycleController>()
        ? Get.find<CycleController>()
        : null;

    if (cycleCtrl != null) {
      try {
        final mortalityEntries = cycleCtrl.getMortalityEntries();
        for (var e in mortalityEntries) {
          if (!_isInWeek(e.date, weekStart, now)) continue;
          totalMortality += e.count;
          uniqueDays.add(_dayKey(e.date));
        }
      } catch (_) {}

      try {
        final weightEntries = cycleCtrl.getAverageWeightEntries();
        for (var e in weightEntries) {
          if (!_isInWeek(e.date, weekStart, now)) continue;
          totalWeightSum += e.weight;
          weightCount++;
          uniqueDays.add(_dayKey(e.date));
        }
      } catch (_) {}

      try {
        final feedEntries = cycleCtrl.getFeedConsumptionEntries();
        for (var e in feedEntries) {
          if (!_isInWeek(e.date, weekStart, now)) continue;
          totalFeed += e.amount;
          uniqueDays.add(_dayKey(e.date));
        }
      } catch (_) {}

      try {
        final rawWater = cycleCtrl.currentCycle['waterConsumptionEntries'];
        if (rawWater is List) {
          for (var e in rawWater) {
            if (e is Map<String, dynamic>) {
              final date = DateTime.tryParse(e['date']?.toString() ?? '');
              final amount = double.tryParse(e['amount']?.toString() ?? '0') ?? 0.0;
              if (date != null && _isInWeek(date, weekStart, now)) {
                totalWater += amount;
                uniqueDays.add(_dayKey(date));
              }
            }
          }
        }
      } catch (_) {}

      try {
        final medEntries = cycleCtrl.getMedicationEntries();
        for (var e in medEntries) {
          if (!_isInWeek(e.date, weekStart, now)) continue;
          if (e.text.isNotEmpty) medications.add(e.text);
          uniqueDays.add(_dayKey(e.date));
        }
      } catch (_) {}
    }

    final currentCycle = cycleCtrl?.currentCycle ?? widget.cycle;

    try {
      final expenses = currentCycle['expenses'];
      if (expenses is List) {
        for (var exp in expenses) {
          final createdAt = exp['created_at']?.toString() ?? '';
          final parsed = _parseDate(createdAt);
          if (parsed == null || !_isInWeek(parsed, weekStart, now)) continue;
          totalExpenses += double.tryParse(exp['amount']?.toString() ?? '0') ?? 0.0;
        }
      }
    } catch (_) {}

    try {
      final sales = currentCycle['sales'];
      if (sales is List) {
        for (var sale in sales) {
          final saleDateStr = sale['sale_date']?.toString() ?? sale['entry_date']?.toString() ?? '';
          final parsed = _parseDate(saleDateStr);
          if (parsed != null && _isInWeek(parsed, weekStart, now)) {
            totalSales += double.tryParse(sale['total_price']?.toString() ?? '0') ?? 0.0;
          }
        }
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<CycleExpensesController>()) {
        final expCtrl = Get.find<CycleExpensesController>();
        for (var item in expCtrl.expenses) {
          for (var payment in item.payments) {
            if (_isInWeek(payment.date, weekStart, now)) {
              totalExpenses += payment.amount;
            }
          }
        }
      }
    } catch (_) {}

    final avgWeight = weightCount > 0 ? totalWeightSum / weightCount : 0.0;

    final chickCount = int.tryParse(
          currentCycle['chickCount']?.toString()
              ?? currentCycle['chick_count']?.toString() ?? '0',
        ) ?? 0;
    final mortality = int.tryParse(currentCycle['mortality']?.toString() ?? '0') ?? 0;
    final liveCount = chickCount - mortality;
    double fcr = 0.0;
    if (totalFeed > 0 && avgWeight > 0 && liveCount > 0) {
      fcr = totalFeed / (liveCount * avgWeight);
    }

    return WeeklyData(
      mortality: totalMortality,
      avgWeight: avgWeight,
      totalFeed: totalFeed,
      totalWater: totalWater,
      fcr: fcr,
      totalExpenses: totalExpenses,
      totalSales: totalSales,
      netProfit: totalSales - totalExpenses,
      medications: medications,
      daysWithData: uniqueDays.length,
    );
  }

  bool _isInWeek(DateTime date, DateTime weekStart, DateTime now) {
    final d = DateTime(date.year, date.month, date.day);
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = DateTime(now.year, now.month, now.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    var d = DateTime.tryParse(raw);
    if (d != null) return d;
    final parts = raw.split('/');
    if (parts.length == 3) {
      d = DateTime.tryParse('${parts[0].padLeft(4, '20')}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}');
      return d;
    }
    return null;
  }
}
