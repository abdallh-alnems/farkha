import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/functions/tool_page_view.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/ad/native.dart';
import '../../../widget/appbar/custom_appbar.dart';
import '../../../widget/tools/disease/disease_card.dart';
import '../../../widget/tools/disease/question_card.dart';
import '../../../widget/tools/related_articles_section.dart';

class DiseasesScreen extends StatelessWidget {
  const DiseasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: DiseasesScreen, toolId: 12);

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: 'الامراض', favoriteToolName: 'الامراض'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  const AdNativeWidget(),
                  const QuestionCard(),
                  const RelatedArticlesSection(relatedArticleIds: [1, 3, 10]),
                  SizedBox(height: 16.h),
                  const DiseaseCard(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
