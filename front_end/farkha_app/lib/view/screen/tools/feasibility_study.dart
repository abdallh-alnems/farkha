import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/feasibility_study/input_section.dart';
import '../../widget/tools/feasibility_study/prices_section.dart';
import '../../widget/tools/feasibility_study/results_section.dart';

class FeasibilityStudy extends StatelessWidget {
  FeasibilityStudy({super.key});

  final FeasibilityController controller = Get.put(FeasibilityController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'دراسة جدوي',
        toolKey: 'feasibilityStudyDialog',
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 21.w),
              child: const Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        // Input Section
                        InputSection(),
                        AdNativeWidget(),

                        // Prices Section
                        PricesSection(),

                        // Results Section
                        ResultsSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 15.h),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
