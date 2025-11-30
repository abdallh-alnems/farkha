import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/class/handling_data.dart';
import '../../../../logic/controller/tools_controller/articles_controller/article_detail_controller.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/ad/native.dart';
import '../../../widget/appbar/custom_appbar.dart';

class ArticleDetail extends StatelessWidget {
  const ArticleDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        Get.arguments as Map<String, dynamic>;
    final String articleId = arguments['id'].toString();
    final String articleTitle = arguments['title'] ?? 'المقال';

    final ArticleDetailController controller = Get.put(
      ArticleDetailController(),
    );
    controller.getArticleDetail(articleId);

    return Scaffold(
      appBar: CustomAppBar(text: articleTitle),
      body: GetBuilder<ArticleDetailController>(
        builder: (controller) {
          return HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: SingleChildScrollView(
              padding: const EdgeInsets.all(17),
              child: Column(
                children: [
                  const AdNativeWidget(),
                  _buildCustomMarkdown(
                    controller.articleData['content'] ?? '',
                    context,
                  ),
                  ...controller.getTableWidgets(articleId, context),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildCustomMarkdown(String content, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          fontSize: 15.sp,
          height: 1.7,
          color: colorScheme.onSurface,
          fontFamily: 'Cairo',
        ),
        h1Padding: const EdgeInsets.only(top: 13),
        h2Padding: const EdgeInsets.only(top: 11),
        h3Padding: const EdgeInsets.only(top: 7),
        h1: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          fontFamily: 'Cairo',
        ),
        h2: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          fontFamily: 'Cairo',
        ),
        h3: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.red[300] : Colors.red,
          fontFamily: 'Cairo',
        ),
      ),
      builders: {
        'h1': CenterHBuilder(),
        'h2': CenterHBuilder(),
        'h3': CenterHBuilder(),
      },
    );
  }
}

class CenterHBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Center(
      child: Text(
        text.text,
        style: preferredStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}
