import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/total_revenue_controller.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class TotalRevenueScreen extends StatefulWidget {
  const TotalRevenueScreen({super.key});

  @override
  State<TotalRevenueScreen> createState() => _TotalRevenueScreenState();
}

class _TotalRevenueScreenState extends State<TotalRevenueScreen>
    with SingleTickerProviderStateMixin {
  final TotalRevenueController controller = Get.put(TotalRevenueController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showResult = false;
  double? lastRevenue;
  double? lastTotalWeight;
  double? lastBirdsCount;
  double? lastAvgWeight;
  double? lastPricePerKg;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    controller.calculate();
    setState(() {
      showResult = true;
      lastRevenue = controller.totalRevenue.value;
      lastTotalWeight = controller.totalWeight;
      lastBirdsCount = controller.birdsCount.value;
      lastAvgWeight = controller.averageWeight.value;
      lastPricePerKg = controller.pricePerKg.value;
    });
    _animController.forward(from: 0);
  }

  void _resetResult() {
    setState(() {
      showResult = false;
      lastRevenue = null;
      lastTotalWeight = null;
      lastBirdsCount = null;
      lastAvgWeight = null;
      lastPricePerKg = null;
    });
    _animController.reset();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: TotalRevenueScreen, toolId: 22);

    final colorScheme = Theme.of(context).colorScheme;

    return ToolPageScaffold(
      title: 'اجمالي الايرادات',
      inputChild: Form(
        key: _formKey,
        child: ThreeInputFields(
          firstLabel: 'عدد الطيور',
          secondLabel: 'متوسط الوزن',
          thirdLabel: 'سعر الكيلو',
          secondHint: 'وزن الفرخ الواحد بالكجم',
          secondSuffix: 'كجم',
          thirdSuffix: 'جنيه',
          onFirstChanged: (v) {
            controller.updateBirdsCount(v);
            _resetResult();
          },
          onSecondChanged: (v) {
            controller.updateAverageWeight(v);
            _resetResult();
          },
          onThirdChanged: (v) {
            controller.updatePricePerKg(v);
            _resetResult();
          },
        ),
      ),
      buttonText: 'احسب الإيرادات',
      onButtonPressed: _onCalculatePressed,
      footerSections: [
        if (showResult && lastRevenue != null && lastRevenue! > 0)
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _RevenueResultSection(
                revenue: lastRevenue!,
                totalWeight: lastTotalWeight!,
                birdsCount: lastBirdsCount!,
                avgWeight: lastAvgWeight!,
                pricePerKg: lastPricePerKg!,
                resultColor: getToolResultColor(context),
                colorScheme: colorScheme,
              ),
            ),
          ),
        SizedBox(height: 16.h),
        const NotesCard(
          notes: [
            'يتم حساب الإيرادات بناءً على عدد الطيور ومتوسط الوزن وسعر الكيلو.',
            'الإيرادات = عدد الطيور × متوسط الوزن × سعر الكيلو.',
            'يجب التأكد من دقة البيانات المدخلة للحصول على نتائج صحيحة.',
          ],
        ),
        SizedBox(height: 16.h),
        const RelatedArticlesSection(relatedArticleIds: [20]),
      ],
    );
  }
}

class _RevenueResultSection extends StatelessWidget {
  final double revenue;
  final double totalWeight;
  final double birdsCount;
  final double avgWeight;
  final double pricePerKg;
  final Color resultColor;
  final ColorScheme colorScheme;

  const _RevenueResultSection({
    required this.revenue,
    required this.totalWeight,
    required this.birdsCount,
    required this.avgWeight,
    required this.pricePerKg,
    required this.resultColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FormulaStrip(colorScheme: colorScheme),
        SizedBox(height: 12.h),
        ToolResultCard(
          title: 'إجمالي الإيرادات',
          value: '${_formatRevenue(revenue)} جنيه',
          resultColor: resultColor,
          badgeLabel: 'إيرادات',
        ),
        SizedBox(height: 10.h),
        _BreakdownCard(
          totalWeight: totalWeight,
          birdsCount: birdsCount,
          avgWeight: avgWeight,
          pricePerKg: pricePerKg,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  String _formatRevenue(double value) {
    if (value == value.roundToDouble()) {
      final formatter = NumberFormat('#,##0');
      return formatter.format(value.toInt());
    }
    return formatDecimal(value);
  }
}

class _FormulaStrip extends StatelessWidget {
  final ColorScheme colorScheme;

  const _FormulaStrip({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppDimens.borderMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.functions,
            size: 18.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'عدد الطيور × متوسط الوزن × سعر الكيلو',
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final double totalWeight;
  final double birdsCount;
  final double avgWeight;
  final double pricePerKg;
  final ColorScheme colorScheme;

  const _BreakdownCard({
    required this.totalWeight,
    required this.birdsCount,
    required this.avgWeight,
    required this.pricePerKg,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _BreakdownRow(
            icon: Icons.pets_outlined,
            label: 'عدد الطيور',
            value: formatDecimal(birdsCount),
            unit: 'طائر',
            colorScheme: colorScheme,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          _BreakdownRow(
            icon: Icons.scale_outlined,
            label: 'متوسط الوزن',
            value: formatDecimal(avgWeight),
            unit: 'كجم',
            colorScheme: colorScheme,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          _BreakdownRow(
            icon: Icons.monitor_weight_outlined,
            label: 'الوزن الكلي',
            value: totalWeight >= 1000
                ? formatDecimal(totalWeight / 1000)
                : formatDecimal(totalWeight),
            unit: totalWeight >= 1000 ? 'طن' : 'كجم',
            highlight: true,
            colorScheme: colorScheme,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Divider(
              height: 1,
              color: colorScheme.outlineVariant,
            ),
          ),
          _BreakdownRow(
            icon: Icons.sell_outlined,
            label: 'سعر الكيلو',
            value: formatDecimal(pricePerKg),
            unit: 'جنيه',
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool highlight;
  final ColorScheme colorScheme;

  const _BreakdownRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.highlight = false,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17.sp,
          color: highlight
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.45),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
            color: highlight
                ? colorScheme.primary
                : colorScheme.onSurface,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
