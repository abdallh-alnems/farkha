import 'package:flutter/material.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/ad/native.dart';
import '../../../widget/app_bar/custom_app_bar.dart';
import '../../../widget/follow_up_tools/disease/disease_card.dart';
import '../../../widget/follow_up_tools/disease/question_card.dart';

class Disease extends StatelessWidget {
  const Disease({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          CustomAppBar(text: "الامراض"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: AdNativeWidget(adIndex: 1),
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
      bottomNavigationBar: const AdBannerWidget(adIndex: 1),
    );
  }
}
