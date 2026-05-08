import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/bird_net_profit_controller.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class BirdNetProfitScreen extends StatefulWidget {
  const BirdNetProfitScreen({super.key});

  @override
  State<BirdNetProfitScreen> createState() => _BirdNetProfitScreenState();
}

class _BirdNetProfitScreenState extends State<BirdNetProfitScreen>
    with SingleTickerProviderStateMixin {
  final BirdNetProfitController controller =
      Get.put(BirdNetProfitController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showResult = false;
  double? lastValidResult;
  double? lastTotalProfit;
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
    controller.calculateNetProfit();
    setState(() {
      showResult = true;
      lastValidResult = controller.netProfit.value;
      lastTotalProfit =
          controller.totalSale.value - controller.totalCost.value;
    });
    _animController.forward(from: 0);
  }

  void _resetResult() {
    setState(() {
      showResult = false;
      lastValidResult = null;
      lastTotalProfit = null;
    });
    _animController.reset();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: BirdNetProfitScreen, toolId: 18);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return ToolPageScaffold(
      title: 'الربح الصافي للطائر',
      inputChild: Form(
        key: _formKey,
        child: ThreeInputFields(
          firstLabel: 'إجمالي مبلغ البيع',
          secondLabel: 'إجمالي التكاليف',
          thirdLabel: 'عدد الطيور المباعة',
          firstSuffix: 'جنيه',
          secondSuffix: 'جنيه',
          onFirstChanged: (value) {
            controller.totalSale.value = double.tryParse(value) ?? 0.0;
            _resetResult();
          },
          onSecondChanged: (value) {
            controller.totalCost.value = double.tryParse(value) ?? 0.0;
            _resetResult();
          },
          onThirdChanged: (value) {
            controller.soldBirds.value = int.tryParse(value) ?? 0;
            _resetResult();
          },
        ),
      ),
      buttonText: 'احسب الربح الصافي للطائر',
      onButtonPressed: _onCalculatePressed,
      footerSections: [
        if (showResult && lastValidResult != null)
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _ResultSection(
                netProfitPerBird: lastValidResult!,
                totalProfit: lastTotalProfit!,
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
  final double netProfitPerBird;
  final double totalProfit;
  final bool isDark;
  final ColorScheme colorScheme;

  const _ResultSection({
    required this.netProfitPerBird,
    required this.totalProfit,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = netProfitPerBird >= 0;
    final resultColor = isProfit
        ? (isDark ? AppColors.darkPrimaryColor : AppColors.successColor)
        : AppColors.errorColor;

    return Column(
      children: [
        _FormulaStrip(colorScheme: colorScheme),
        SizedBox(height: 12.h),
        ToolResultCard(
          title: isProfit
              ? 'الربح الصافي للطائر'
              : 'الخسارة الصافية للطائر',
          value: '${formatDecimal(netProfitPerBird.abs())} جنيه',
          resultColor: resultColor,
          badgeLabel: isProfit ? 'ربح' : 'خسارة',
        ),
        SizedBox(height: 8.h),
        _TotalProfitRow(
          totalProfit: totalProfit,
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
              '(إجمالي البيع − إجمالي التكاليف) ÷ عدد الطيور',
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

class _TotalProfitRow extends StatelessWidget {
  final double totalProfit;
  final Color color;
  final ColorScheme colorScheme;

  const _TotalProfitRow({
    required this.totalProfit,
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
                totalProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 18.sp,
                color: color,
              ),
              SizedBox(width: 6.w),
              Text(
                'إجمالي الربح',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Text(
            '${formatDecimal(totalProfit)} جنيه',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
