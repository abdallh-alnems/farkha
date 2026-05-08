import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/total_farm_weight_controller.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';
import '../../widget/tools/total_farm_weight_widgets.dart';

class TotalFarmWeightScreen extends StatefulWidget {
  const TotalFarmWeightScreen({super.key});

  @override
  State<TotalFarmWeightScreen> createState() => _TotalFarmWeightScreenState();
}

class _TotalFarmWeightScreenState extends State<TotalFarmWeightScreen>
    with SingleTickerProviderStateMixin {
  final TotalFarmWeightController controller =
      Get.put(TotalFarmWeightController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnim = CurvedAnimation(
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
    ever(controller.totalWeight, (_) {
      if (controller.totalWeight.value > 0 && mounted) {
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
    controller.calculate();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: TotalFarmWeightScreen, toolId: 21);

    return ToolPageScaffold(
      title: 'الوزن الاجمالي',
      inputChild: Form(
        key: _formKey,
        child: TwoInputFields(
          firstLabel: 'عدد الطيور',
          secondLabel: 'متوسط الوزن للفرخ',
          firstHint: 'مثال: 10000',
          secondHint: 'وزن فرخ واحد بالكجم',
          firstSuffix: 'طائر',
          secondSuffix: 'كجم',
          onFirstChanged: (val) {
            controller.birdsCount.value = val;
            controller.totalWeight.value = 0.0;
          },
          onSecondChanged: (val) {
            controller.birdWeight.value = val;
            controller.totalWeight.value = 0.0;
          },
        ),
      ),
      buttonText: 'احسب الوزن الإجمالي',
      onButtonPressed: _onCalculatePressed,
      footerSections: [
        Obx(() {
          final totalWeight = controller.totalWeight.value;
          if (totalWeight <= 0) return const SizedBox.shrink();

          final birds = int.tryParse(controller.birdsCount.value) ?? 0;
          final weight =
              double.tryParse(controller.birdWeight.value) ?? 0.0;

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  const FormulaStrip(),
                  SizedBox(height: 12.h),
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                      _scaleAnim,
                    ),
                    child: ToolResultCard(
                      title: 'الوزن الإجمالي للقطيع',
                      value:
                          '${formatDecimal(totalWeight, decimals: 0)} كيلو جرام',
                      resultColor: getToolResultColor(context),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  WeightBreakdown(
                    birds: birds,
                    avgWeight: weight,
                    totalWeight: totalWeight,
                  ),
                  SizedBox(height: 8.h),
                  TonConversionCard(totalWeightKg: totalWeight),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 16.h),
        const StepByStepGuide(),
        SizedBox(height: 16.h),
        const NotesCard(
          notes: [
            'لحساب الوزن الكلي للقطيع: وزّن 10 فراخ عشوائيًا، احسب متوسط الوزن (قسمة على 10)، ثم اضربه في عدد الطيور.',
            'كلما زاد عدد العينات المأخوذة، زادت دقة متوسط الوزن المحسوب.',
          ],
        ),
        SizedBox(height: 16.h),
        const RelatedArticlesSection(relatedArticleIds: [13, 8]),
      ],
    );
  }
}
