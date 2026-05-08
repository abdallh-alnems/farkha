import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/shared/snackbar_message.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../widget/cycle/comparison/comparison_cards.dart';
import '../../widget/cycle/comparison/comparison_results.dart';
import '../../widget/cycle/comparison/comparison_widgets.dart';

class CycleComparisonScreen extends StatefulWidget {
  const CycleComparisonScreen({super.key});

  @override
  State<CycleComparisonScreen> createState() => _CycleComparisonScreenState();
}

class _CycleComparisonScreenState extends State<CycleComparisonScreen>
    with SingleTickerProviderStateMixin {
  late final CycleController cycleCtrl;
  final RxList<Map<String, dynamic>> _selectedCycles =
      <Map<String, dynamic>>[].obs;
  final RxBool _showResults = false.obs;
  final RxBool _isLoading = true.obs;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    cycleCtrl =
        Get.isRegistered<CycleController>()
            ? Get.find<CycleController>()
            : Get.put(CycleController());
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (cycleCtrl.historyCycles.isEmpty) {
      await cycleCtrl.fetchHistory(isRefresh: true);
    }
    if (mounted) {
      _isLoading.value = false;
      _fadeController.forward();
    }
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
      SnackbarMessage.showWarning(
        context,
        'يمكنك مقارنة 3 دورات كحد أقصى',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مقارنة الدورات',
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            if (_selectedCycles.length >= 2 && !_showResults.value) {
              return Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: CompareButton(
                  count: _selectedCycles.length,
                  onTap: () {
                    _showResults.value = true;
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }
        if (_showResults.value) {
          return _buildComparisonResults();
        }
        return FadeTransition(
          opacity: _fadeAnimation,
          child: _buildCycleSelection(),
        );
      }),
    );
  }

  Widget _buildCycleSelection() {
    final colorScheme = Theme.of(context).colorScheme;
    final allCycles = _allCycles;
    final selectedLen = _selectedCycles.length;

    if (allCycles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.compare_arrows_rounded,
                size: 40.sp,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'لا توجد دورات للمقارنة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SelectionHintBar(selectedCount: selectedLen, totalCount: 3),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
              vertical: AppSpacing.sm,
            ),
            itemCount: allCycles.length,
            itemBuilder: (context, index) {
              final cycle = allCycles[index];
              final id = cycle['cycle_id']?.toString();
              final isSelected = _selectedCycles.any(
                (c) => c['cycle_id']?.toString() == id,
              );

              return CycleSelectionCard(
                cycle: cycle,
                isSelected: isSelected,
                selectionIndex: isSelected
                    ? _selectedCycles.indexWhere(
                        (c) => c['cycle_id']?.toString() == id,
                      )
                    : -1,
                onTap: () => _toggleSelection(cycle),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonResults() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cycles = _selectedCycles.toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'نتائج المقارنة',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showResults.value = false,
                icon: Icon(Icons.swap_horiz_rounded, size: 18.sp),
                label: Text(
                  'تغيير',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          CycleHeaderRow(cycles: cycles),
          SizedBox(height: AppSpacing.md),
          ComparisonSectionCard(
            title: 'معلومات الدورة',
            icon: Icons.info_outline_rounded,
            metrics: [
              MetricDef(
                'العدد الأولي',
                'chickCount',
                'يوم',
                isCount: true,
              ),
              MetricDef('النافق', 'mortality', '', isCount: true),
              MetricDef('نسبة النفوق', 'mortality_rate', '%'),
              MetricDef('مدة الدورة', 'cycle_age', 'يوم', isCount: true),
              MetricDef('السلالة', 'breed', '', isText: true),
              MetricDef('نظام التربية', 'systemType', '', isText: true),
            ],
            cycles: cycles,
            lowerIsBetter: const {'mortality', 'mortality_rate'},
          ),
          SizedBox(height: AppSpacing.md),
          ComparisonSectionCard(
            title: 'الأداء الإنتاجي',
            icon: Icons.bar_chart_rounded,
            metrics: [
              MetricDef('متوسط الوزن', 'average_weight', 'كجم'),
              MetricDef(
                'معامل التحويل',
                'fcr',
                '',
                lowerBetter: true,
              ),
              MetricDef('تكلفة الفرخ', 'cost_per_bird', 'ج'),
              MetricDef('إجمالي العلف', 'total_feed', 'كجم'),
            ],
            cycles: cycles,
            lowerIsBetter: const {'fcr'},
          ),
          SizedBox(height: AppSpacing.md),
          ComparisonSectionCard(
            title: 'المالية',
            icon: Icons.account_balance_wallet_rounded,
            metrics: [
              MetricDef('المصروفات', 'total_expenses', 'ج'),
              MetricDef('المبيعات', 'total_sales', 'ج'),
              MetricDef('صافي الربح', 'net_profit', 'ج'),
            ],
            cycles: cycles,
            lowerIsBetter: const {'total_expenses'},
          ),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
