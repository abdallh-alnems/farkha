import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/input_field.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/chicken_density_controller.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class ChickenDensity extends StatefulWidget {
  const ChickenDensity({super.key});

  @override
  State<ChickenDensity> createState() => _ChickenDensityState();
}

class _ChickenDensityState extends State<ChickenDensity>
    with SingleTickerProviderStateMixin {
  final ChickenDensityController controller =
      Get.put(ChickenDensityController());
  bool _showResult = false;
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
      begin: const Offset(0, 0.1),
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

  void _onCalculate() {
    controller.calculateAreas();
    if (controller.shouldDisplayResults.value) {
      setState(() => _showResult = true);
      _animController.forward(from: 0);
    }
  }

  void _resetResult() {
    if (_showResult) {
      setState(() => _showResult = false);
      _animController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: ChickenDensity, toolId: 3);

    final colorScheme = Theme.of(context).colorScheme;
    final resultColor = getToolResultColor(context);

    return ToolPageScaffold(
      title: 'كثافة الفراخ',
      inputChild: _InputSection(
        controller: controller,
        colorScheme: colorScheme,
        onChanged: _resetResult,
      ),
      buttonText: 'احسب الكثافة',
      onButtonPressed: _onCalculate,
      footerSections: [
        if (_showResult && controller.shouldDisplayResults.value)
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _ResultSection(
                controller: controller,
                resultColor: resultColor,
                colorScheme: colorScheme,
              ),
            ),
          ),
        SizedBox(height: 14.h),
        _DensityInfoStrip(colorScheme: colorScheme),
        SizedBox(height: 14.h),
        const RelatedArticlesSection(relatedArticleIds: [4]),
      ],
    );
  }
}

class _InputSection extends StatelessWidget {
  final ChickenDensityController controller;
  final ColorScheme colorScheme;
  final VoidCallback onChanged;

  const _InputSection({
    required this.controller,
    required this.colorScheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: controller.selectedAgeCategory.value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'اختر الأسبوع',
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              size: 20.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          dropdownColor: colorScheme.surface,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 15.sp,
          ),
          items: ChickenDensityController.weekLabels.map((week) {
            return DropdownMenuItem<String>(
              value: week,
              child: Text(
                week,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15.sp, color: colorScheme.onSurface),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.selectedAgeCategory.value = value;
              onChanged();
            }
          },
        ),
        SizedBox(height: 14.h),
        InputField(
          label: 'عدد الفراخ',
          controller: controller.chickenCountTextController,
          suffixText: 'فرخ',
          enableValidation: false,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  final ChickenDensityController controller;
  final Color resultColor;
  final ColorScheme colorScheme;

  const _ResultSection({
    required this.controller,
    required this.resultColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final batteryColor =
        isDark ? AppColors.secondaryLight : AppColors.secondaryColor;

    return Column(
      children: [
        ToolResultCard(
          title: 'مساحة التربية الأرضية حسب العمر',
          value: _extractAreaValue(
            controller.currentAgeGroundAreaResult.value,
          ),
          resultColor: resultColor,
          badgeLabel: controller.selectedAgeCategory.value,
        ),
        SizedBox(height: 8.h),
        _AreaDetailRow(
          icon: Icons.straighten_outlined,
          label: 'المساحة الكلية حتى البيع',
          value: _extractAreaValue(
            controller.totalGroundAreaResult.value,
          ),
          color: resultColor,
          colorScheme: colorScheme,
        ),
        SizedBox(height: 8.h),
        ToolResultCard(
          title: 'مساحة البطاريات',
          value: controller.batteryCageAreaResult.value,
          resultColor: batteryColor,
        ),
      ],
    );
  }

  String _extractAreaValue(String fullText) {
    final match = RegExp(r'(\d[\d,]*\.?\d*)\s*م²').firstMatch(fullText);
    if (match != null) return '${match.group(1)} م²';
    final lastColon = fullText.lastIndexOf(':');
    if (lastColon != -1) return fullText.substring(lastColon + 1).trim();
    return fullText;
  }
}

class _AreaDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ColorScheme colorScheme;

  const _AreaDetailRow({
    required this.icon,
    required this.label,
    required this.value,
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
              Icon(icon, size: 18.sp, color: color),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          Text(
            value,
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

class _DensityInfoStrip extends StatelessWidget {
  final ColorScheme colorScheme;

  const _DensityInfoStrip({required this.colorScheme});

  static const _densityRanges = [
    ('الأسبوع الأول', 'يوم 1 – يوم 7', '30 فرخ/م²'),
    ('الأسبوع الثاني', 'يوم 8 – يوم 14', '25 فرخ/م²'),
    ('الأسبوع الثالث', 'يوم 15 – يوم 21', '20 فرخ/م²'),
    ('الأسبوع الرابع', 'يوم 22 – يوم 28', '15 فرخ/م²'),
    ('الأسبوع الخامس', 'يوم 29 – يوم 35', '10 فرخ/م²'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18.sp,
                color: colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                'كثافة التربية الموصى بها',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ..._densityRanges.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item.$2,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: AppDimens.borderXl,
                    ),
                    child: Text(
                      item.$3,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
