import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/tools/tool_input_card.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/adg_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class AverageDailyGain extends StatefulWidget {
  AverageDailyGain({super.key});
  final AdgController controller = Get.put(AdgController());

  @override
  State<AverageDailyGain> createState() => _AverageDailyGainState();
}

class _AverageDailyGainState extends State<AverageDailyGain> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    widget.controller.calculateADG();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: AverageDailyGain, toolId: 2);

    return Scaffold(
      appBar: const CustomAppBar(text: 'متوسط النمو اليومي', favoriteToolName: 'متوسط النمو اليومي'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolInputCard(
                child: TwoInputFields(
                  formKey: _formKey,
                  firstLabel: 'العمر',
                  secondLabel: 'متوسط الوزن الحالي للفرخ',
                  firstController: widget.controller.daysController,
                  secondController: widget.controller.currentWeightKgController,
                  firstSuffix: 'يوم',
                  secondSuffix: 'كجم',
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(text: 'احسب ADG', onPressed: _onCalculatePressed),
              SizedBox(height: 14.h),
              Obx(() {
                final value = widget.controller.adg.value;
                final quality = widget.controller.getAdgQuality();
                if (value <= 0) return const SizedBox.shrink();

                final resultColor = getQualityColor(quality);
                final label = getQualityLabel(quality);

                return ToolResultCard(
                  title: 'متوسط الزيادة اليومية (ADG)',
                  value: '${formatDecimal(value, decimals: 2)} جرام/يوم',
                  resultColor: resultColor,
                  badgeLabel: label,
                );
              }),
              const NotesCard(
                notes: [
                  'بعد عمر 7 أيام يفضل حساب متوسط زيادة الوزن',
                  'ارتفاع متوسط زيادة الوزن يدل على سرعة نمو جيدة',
                  'لحساب الوزن الكلي للقطيع : اوزن 10 فراخ عشوائيًا احسب متوسط الوزن (قسمة على 10) ثم اضربه في عدد الطيور',
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
