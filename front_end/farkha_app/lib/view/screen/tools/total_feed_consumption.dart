import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/input_field.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/total_feed_consumption_controller.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class TotalFeedConsumption extends StatefulWidget {
  TotalFeedConsumption({super.key});
  final TotalFeedConsumptionController controller =
      Get.put(TotalFeedConsumptionController());

  @override
  State<TotalFeedConsumption> createState() => _TotalFeedConsumptionState();
}

class _TotalFeedConsumptionState extends State<TotalFeedConsumption>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    );
    ever(widget.controller.totalResult, (_) {
      if (widget.controller.totalResult.value > 0 && mounted) {
        _animController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    widget.controller.calculateTotalFeedConsumption();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: TotalFeedConsumption, toolId: 5);

    final resultColor = getToolResultColor(context);

    return ToolPageScaffold(
      title: 'استهلاك العلف الكلي',
      inputChild: Form(
        key: _formKey,
        child: InputField(
          label: 'عدد الفراخ',
          controller: widget.controller.textController,
          suffixText: 'فرخ',
        ),
      ),
      buttonText: 'احسب الاستهلاك الكلي',
      onButtonPressed: _onCalculatePressed,
      footerSections: [
        Obx(() {
          final total = widget.controller.totalResult.value;
          if (total <= 0) return const SizedBox.shrink();

          return FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale:
                  Tween<double>(begin: 0.92, end: 1.0).animate(_scaleAnim),
              child: Column(
                children: [
                  ToolResultCard(
                    title:
                        'استهلاك ${widget.controller.chickenCount.value} فرخ طوال الدورة',
                    value: '${formatDecimal(total, decimals: 0)} كجم',
                    resultColor: resultColor,
                  ),
                  SizedBox(height: 8.h),
                  _BreakdownCard(controller: widget.controller),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 16.h),
        const NotesCard(
          notes: [
            'بادي: 0.5 كجم لكل فرخ',
            'نامي: 1.2 كجم لكل فرخ',
            'ناهي: 1.8 كجم لكل فرخ',
            'الإجمالي: 3.5 كجم لكل فرخ في الدورة الكاملة',
          ],
        ),
        const RelatedArticlesSection(relatedArticleIds: [12]),
      ],
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final TotalFeedConsumptionController controller;

  const _BreakdownCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
              : AppColors.lightOutlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: AppDimens.borderSm,
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primaryColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'تفصيل الاستهلاك',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _FeedRow(
            label: 'العلف البادي',
            value: controller.badiResult.value,
            perBird: 0.5,
            color: AppColors.primaryColor,
            icon: Icons.grain_outlined,
            isDark: isDark,
          ),
          SizedBox(height: 14.h),
          _FeedRow(
            label: 'العلف النامي',
            value: controller.namiResult.value,
            perBird: 1.2,
            color: AppColors.secondaryColor,
            icon: Icons.eco_outlined,
            isDark: isDark,
          ),
          SizedBox(height: 14.h),
          _FeedRow(
            label: 'العلف الناهي',
            value: controller.nahiResult.value,
            perBird: 1.8,
            color: AppColors.accentColor,
            icon: Icons.local_dining_outlined,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _FeedRow extends StatelessWidget {
  final String label;
  final double value;
  final double perBird;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _FeedRow({
    required this.label,
    required this.value,
    required this.perBird,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final barFraction = (perBird / 3.5).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ),
            Text(
              '${formatDecimal(value, decimals: 0)} كجم',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Stack(
                  children: [
                    Container(
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkOutlineColor
                                .withValues(alpha: 0.3)
                            : AppColors.lightOutlineColor
                                .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: barFraction,
                      child: Container(
                        height: 8.h,
                        decoration: BoxDecoration(
                          color:
                              color.withValues(alpha: isDark ? 0.7 : 0.8),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '${formatDecimal(perBird)} كجم/فرخ',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
