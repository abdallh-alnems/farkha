import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../logic/controller/tool_usage_controller.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/ad/native.dart';
import '../../../widget/app_bar/custom_app_bar.dart';
import '../../../widget/tools/disease/disease_card.dart';
import '../../../widget/tools/disease/question_card.dart';

class Disease extends StatefulWidget {
  const Disease({super.key});

  @override
  State<Disease> createState() => _DiseaseState();
}

class _DiseaseState extends State<Disease> {
  late ToolUsageController toolUsageController;

  @override
  void initState() {
    super.initState();
    toolUsageController = Get.find<ToolUsageController>();
    // Record tool usage when entering this page
    toolUsageController.recordToolUsage(12); // Diseases tool ID = 12
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          CustomAppBar(text: "الامراض"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: AdNativeWidget(),
                    ),
                    QuestionCard(),
                    DiseaseCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdBannerWidget(),
    );
  }
}
