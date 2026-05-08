import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/three_input_fields.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/feed_cost_per_bird_controller.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class FeedCostPerBirdScreen extends StatefulWidget {
  const FeedCostPerBirdScreen({super.key});

  @override
  State<FeedCostPerBirdScreen> createState() => _FeedCostPerBirdScreenState();
}

class _FeedCostPerBirdScreenState extends State<FeedCostPerBirdScreen>
    with SingleTickerProviderStateMixin {
  final FeedCostPerBirdController controller =
      Get.put(FeedCostPerBirdController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showResult = false;
  double? lastCostPerBird;
  double? lastTotalCost;
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
    controller.calculateFeedCostPerBird();
    setState(() {
      showResult = true;
      lastCostPerBird = controller.feedCostPerBird.value;
      lastTotalCost =
          controller.totalFeedQuantity.value * controller.feedPricePerTon.value;
    });
    _animController.forward(from: 0);
  }

  void _resetResult() {
    setState(() {
      showResult = false;
      lastCostPerBird = null;
      lastTotalCost = null;
    });
    _animController.reset();
    controller.resetCalculation();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: FeedCostPerBirdScreen, toolId: 16);

    final colorScheme = Theme.of(context).colorScheme;

    return ToolPageScaffold(
      title: 'تكلفة العلف لكل طائر',
      inputChild: Form(
        key: _formKey,
        child: ThreeInputFields(
          firstLabel: 'كمية العلف (بالطن)',
          secondLabel: 'سعر طن العلف',
          thirdLabel: 'عدد الطيور',
          firstSuffix: 'طن',
          secondSuffix: 'جنيه',
          onFirstChanged: (value) {
            controller.totalFeedQuantity.value =
                double.tryParse(value) ?? 0.0;
            _resetResult();
          },
          onSecondChanged: (value) {
            controller.feedPricePerTon.value =
                double.tryParse(value) ?? 0.0;
            _resetResult();
          },
          onThirdChanged: (value) {
            controller.numberOfBirds.value = int.tryParse(value) ?? 0;
            _resetResult();
          },
        ),
      ),
      buttonText: 'احسب تكلفة العلف لكل طائر',
      onButtonPressed: _onCalculatePressed,
      footerSections: [
        if (showResult && lastCostPerBird != null)
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _ResultSection(
                costPerBird: lastCostPerBird!,
                totalCost: lastTotalCost!,
                colorScheme: colorScheme,
              ),
            ),
          ),
        SizedBox(height: 16.h),
        const RelatedArticlesSection(relatedArticleIds: [12]),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  final double costPerBird;
  final double totalCost;
  final ColorScheme colorScheme;

  const _ResultSection({
    required this.costPerBird,
    required this.totalCost,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = getToolResultColor(context);

    return Column(
      children: [
        _FormulaStrip(colorScheme: colorScheme),
        SizedBox(height: 12.h),
        ToolResultCard(
          title: 'تكلفة العلف لكل طائر',
          value: '${formatDecimal(costPerBird)} جنيه',
          resultColor: resultColor,
          badgeLabel: 'لكل طائر',
        ),
        SizedBox(height: 8.h),
        _TotalCostRow(
          totalCost: totalCost,
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
              '(كمية العلف × سعر الطن) ÷ عدد الطيور',
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

class _TotalCostRow extends StatelessWidget {
  final double totalCost;
  final Color color;
  final ColorScheme colorScheme;

  const _TotalCostRow({
    required this.totalCost,
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
                Icons.grain_outlined,
                size: 18.sp,
                color: color,
              ),
              SizedBox(width: 6.w),
              Text(
                'إجمالي تكلفة العلف',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Text(
            '${formatDecimal(totalCost)} جنيه',
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
