import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/theme/color.dart';
import '../../../../logic/controller/calculate_controller/feasibility_study_controller.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/calculate/feasibility_study/feasibility_study_content.dart';
import '../../../widget/app_bar/custom_app_bar.dart';

class HowToDoAFeasibilityStudy extends StatelessWidget {
  const HowToDoAFeasibilityStudy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'عوامل دراسة الجدوي'),
      body: Column(
        children: [
          GetBuilder<FeasibilityController>(
            builder: (controller) {
              controller.ensureFeasibilityData();

              return HandlingDataView(
                statusRequest: controller.statusRequest,
                widget: Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 17,
                        horizontal: 13,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PopupMenuButton(
                                padding: EdgeInsets.zero,
                                tooltip: '',
                                offset: const Offset(0, 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        child: SizedBox(
                                          width: 200,
                                          child: const Text(
                                            "هذه الأسعار هي أسعار اليوم",
                                            style: TextStyle(fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                child: Icon(
                                  Icons.help_outline,
                                  size: 18,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "الأسعار المستخدمة",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          FeasibilityStudyContent(controller: controller),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(adIndex: 2),
    );
  }
}
