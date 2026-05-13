import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/return_on_investment_controller.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class ReturnOnInvestment extends StatefulWidget {
  const ReturnOnInvestment({super.key});

  @override
  State<ReturnOnInvestment> createState() => _ReturnOnInvestmentState();
}

class _ReturnOnInvestmentState extends State<ReturnOnInvestment>
    with SingleTickerProviderStateMixin {
  final ReturnOnInvestmentController controller =
      Get.put(ReturnOnInvestmentController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool showResult = false;
  double? lastRoi;
  double? lastNetProfit;
  double? lastInvestment;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    final investment = controller.investmentCost.value;
    final totalSale = controller.totalSale.value;
    final actualProfit = totalSale - investment;
    controller.netProfit.value = actualProfit;
    controller.calculateROI();
    setState(() {
      showResult = true;
      lastRoi = controller.roi.value;
      lastNetProfit = actualProfit;
      lastInvestment = investment;
    });
    _animController.forward(from: 0);
  }

  void _resetResult() {
    setState(() {
      showResult = false;
      lastRoi = null;
      lastNetProfit = null;
      lastInvestment = null;
    });
    _animController.reset();
    controller.resetCalculation();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: ReturnOnInvestment, toolId: 19);

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ToolPageScaffold(
      title: 'العائد على الاستثمار',
      inputChild: Form(
        key: _formKey,
        child: TwoInputFields(
          firstLabel: 'إجمالي مبلغ البيع',
          secondLabel: 'تكلفة الدورة',
          firstSuffix: 'جنيه',
          secondSuffix: 'جنيه',
          onFirstChanged: (value) {
            controller.totalSale.value = tryParseNum(value) ?? 0.0;
            _resetResult();
          },
          onSecondChanged: (value) {
            controller.investmentCost.value = tryParseNum(value) ?? 0.0;
            _resetResult();
          },
        ),
      ),
      buttonText: 'احسب العائد على الاستثمار',
      onButtonPressed: _onCalculatePressed,
      footerSections: [
        if (showResult && lastRoi != null)
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _ResultSection(
                roi: lastRoi!,
                netProfit: lastNetProfit!,
                investment: lastInvestment!,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ),
          ),
        SizedBox(height: 16.h),
        const RelatedArticlesSection(relatedArticleIds: [20]),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  final double roi;
  final double netProfit;
  final double investment;
  final bool isDark;
  final ColorScheme colorScheme;

  const _ResultSection({
    required this.roi,
    required this.netProfit,
    required this.investment,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = netProfit >= 0;
    final resultColor = isProfit
        ? getToolResultColor(context)
        : AppColors.errorColor;

    return Column(
      children: [
        _FormulaStrip(colorScheme: colorScheme),
        SizedBox(height: 12.h),
        ToolResultCard(
          title: 'العائد على الاستثمار',
          value: '${formatDecimal(netProfit)} جنيه (%${formatDecimal(roi)})',
          resultColor: resultColor,
          badgeLabel: isProfit ? 'ربح' : 'خسارة',
        ),
        SizedBox(height: 8.h),
        _InvestmentBreakdownRow(
          netProfit: netProfit,
          investment: investment,
          color: resultColor,
          colorScheme: colorScheme,
        ),
      ],
    );
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
              '(إجمالي البيع − تكلفة الدورة) ÷ تكلفة الدورة × 100',
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

class _InvestmentBreakdownRow extends StatelessWidget {
  final double netProfit;
  final double investment;
  final Color color;
  final ColorScheme colorScheme;

  const _InvestmentBreakdownRow({
    required this.netProfit,
    required this.investment,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 18.sp,
                color: color,
              ),
              SizedBox(width: 6.w),
              Text(
                'تكلفة الدورة',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Text(
            '${formatDecimal(investment)} جنيه',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
