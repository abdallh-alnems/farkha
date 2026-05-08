import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../../logic/controller/tools_controller/vaccination_controller.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';
import '../../widget/tools/vaccination_schedule_widgets.dart';

class VaccinationSchedule extends StatefulWidget {
  const VaccinationSchedule({super.key});

  @override
  State<VaccinationSchedule> createState() => _VaccinationScheduleState();
}

class _VaccinationScheduleState extends State<VaccinationSchedule>
    with SingleTickerProviderStateMixin {
  final VaccinationController controller = Get.put(VaccinationController());
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
      begin: const Offset(0, 0.08),
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

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: VaccinationSchedule, toolId: 10);

    return ToolPageScaffold(
      title: 'جدول التحصينات',
      inputChild: Obx(() {
        return AgeDropdown(
          key: ValueKey(controller.currentAge.value),
          selectedAge:
              controller.currentAge.value == 0
                  ? null
                  : controller.currentAge.value,
          onAgeChanged: (age) {
            controller.setCurrentAge(age);
            _animController.forward(from: 0);
          },
          maxAge: 30,
          hint: 'اختر العمر',
        );
      }),
      footerSections: [
        Obx(() {
          if (controller.currentAge.value == 0) {
            return const SizedBox.shrink();
          }

          final current = controller.currentVaccination.value;
          final next = controller.nextVaccination.value;
          final selectedAge = controller.currentAge.value;

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  VaccinationCurrentCard(
                    vaccination: current,
                    selectedAge: selectedAge,
                  ),
                  if (next != null) ...[
                    SizedBox(height: 10.h),
                    VaccinationNextCard(
                      vaccination: next,
                      selectedAge: selectedAge,
                    ),
                  ],
                  SizedBox(height: 18.h),
                  VaccinationFullTimeline(selectedAge: selectedAge),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 14.h),
        const RelatedArticlesSection(relatedArticleIds: [17]),
      ],
    );
  }
}
