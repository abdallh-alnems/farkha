import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/functions/tool_page_view.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/ad/native.dart';
import '../../../widget/appbar/custom_appbar.dart';
import '../../../widget/tools/disease/disease_card.dart';
import '../../../widget/tools/disease/question_card.dart';
import '../../../widget/tools/related_articles_section.dart';

class Disease extends StatelessWidget {
  const Disease({super.key});

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: Disease, toolName: 'الأمراض');

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: 'الامراض', favoriteToolName: 'الامراض'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: AdNativeWidget(),
                    ),
                    const QuestionCard(),
                    const RelatedArticlesSection(relatedArticleIds: [1, 3, 10]),
                    SizedBox(height: 20.h),
                    const DiseaseCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
