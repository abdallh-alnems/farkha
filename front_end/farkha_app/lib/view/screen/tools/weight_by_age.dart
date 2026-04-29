import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../logic/controller/tools_controller/weight_by_age_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';

class WeightByAgeScreen extends StatefulWidget {
  const WeightByAgeScreen({super.key});

  @override
  State<WeightByAgeScreen> createState() => _WeightByAgeScreenState();
}

class _WeightByAgeScreenState extends State<WeightByAgeScreen> {
  final WeightByAgeController controller = Get.put(WeightByAgeController());
  bool showResult = false;

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: WeightByAgeScreen, toolId: 6);

    return Scaffold(
      appBar: const CustomAppBar(text: 'الوزن حسب العمر', favoriteToolName: 'الوزن حسب العمر'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Minimal dropdown for day selection
              AgeDropdown(
                selectedAge: controller.selectedAge.value,
                onAgeChanged: (value) {
                  controller.selectedAge.value = value;
                  controller.calculateWeight();
                  setState(() {
                    showResult = true;
                  });
                },
                hint: 'اختر العمر',
              ),
              const SizedBox(height: 20),
              const AdNativeWidget(),
              const SizedBox(height: 20),
              if (showResult)
                Obx(() {
                  final weight = controller.weight.value;
                  final colorScheme = Theme.of(context).colorScheme;
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Card(
                    color: isDark
                        ? AppColors.darkSurfaceElevatedColor
                        : AppColors.lightSurfaceColor,
                    elevation: isDark ? 0 : 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
                            : AppColors.lightOutlineColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$weight',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            'جرام',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                          ),
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
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
