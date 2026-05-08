import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../../data/data_source/static/chicken_data.dart';
import '../../../logic/controller/tools_controller/weight_by_age_controller.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class WeightByAgeScreen extends StatefulWidget {
  const WeightByAgeScreen({super.key});

  @override
  State<WeightByAgeScreen> createState() => _WeightByAgeScreenState();
}

class _WeightByAgeScreenState extends State<WeightByAgeScreen>
    with SingleTickerProviderStateMixin {
  final WeightByAgeController controller = Get.put(WeightByAgeController());
  bool showResult = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: WeightByAgeScreen, toolId: 6);

    return ToolPageScaffold(
      title: 'الوزن حسب العمر',
      inputChild: AgeDropdown(
        selectedAge: controller.selectedAge.value,
        onAgeChanged: (value) {
          controller.selectedAge.value = value;
          controller.calculateWeight();
          setState(() {
            showResult = true;
          });
          _animController.forward(from: 0);
        },
        hint: 'اختر العمر',
      ),
      footerSections: [
        if (showResult)
          Obx(() {
            final weight = controller.weight.value;
            final age = controller.selectedAge.value;
            if (weight <= 0 || age == null) return const SizedBox.shrink();
            return FadeTransition(
              opacity: _fadeAnim,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 14.h * (1 - _animController.value)),
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    _WeightResultCard(
                      weight: weight,
                      age: age,
                      animController: _animController,
                    ),
                    SizedBox(height: 14.h),
                    _GrowthBarCard(weight: weight, age: age),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 32),
        const NotesCard(
          notes: [
            'الوزن المتوقع يعتمد على السلالة ونوع العلف وجودة الرعاية.',
            'يتم حساب الوزن بناءً على متوسطات عالمية للدجاج البياض.',
            'الوزن الفعلي قد يختلف حسب الظروف البيئية والإدارية.',
            'يفضل وزن عينة من الطيور للمقارنة مع الأوزان المتوقعة.',
          ],
        ),
        const RelatedArticlesSection(relatedArticleIds: [13]),
      ],
    );
  }
}

class _WeightResultCard extends StatelessWidget {
  final int weight;
  final int age;
  final AnimationController animController;

  const _WeightResultCard({
    required this.weight,
    required this.age,
    required this.animController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isKg = weight >= 1000;
    final displayValue = isKg ? (weight / 1000).toStringAsFixed(1) : '$weight';
    final unit = isKg ? 'كجم' : 'جرام';
    final primaryColor = colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderXl,
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                AppElevation.shadow(opacity: 0.06),
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: animController,
            builder: (context, child) {
              final scale = 0.85 + (0.15 * Curves.easeOutQuart.transform(animController.value));
              return Transform.scale(scale: scale, child: child);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),
                SizedBox(width: 8.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'الوزن المتوقع',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'اليوم $age',
            style: TextStyle(
              fontSize: 11.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
         ],
       ),
     );
   }
}

class _GrowthBarCard extends StatelessWidget {
  final int weight;
  final int age;

  const _GrowthBarCard({required this.weight, required this.age});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final maxWeight = weightsList.isNotEmpty ? weightsList.last : 1;
    final progress = (weight / maxWeight).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.3),
        ),
        boxShadow: isDark ? null : [AppElevation.shadow(opacity: 0.04)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, size: 18.sp, color: colorScheme.primary),
              SizedBox(width: 8.w),
              Text(
                'مسار النمو',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _ProgressTrack(progress: progress),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '40 جرام',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              Text(
                '$maxWeight جرام',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  final double progress;

  const _ProgressTrack({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            Container(
              height: 10.h,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 10.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.r),
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.6),
                      primaryColor,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: width * progress - 7,
              top: -2.h,
              child: Container(
                width: 14.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkSurfaceColor : Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
