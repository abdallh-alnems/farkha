import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/theme/theme.dart';
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

    final ArticleDetailController controller = Get.put(
      ArticleDetailController(),
    );
    controller.getArticleDetail(articleId);

    return Scaffold(
      appBar: CustomAppBar(text: (arguments['title'] ?? '').toString()),
      body: GetBuilder<ArticleDetailController>(
        builder: (controller) {
          return HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
                vertical: 8.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AdNativeWidget(),
                  SizedBox(height: 12.h),
                  _buildCustomMarkdown(
                    (controller.articleData['content'] ?? '').toString(),
                    context,
                  ),
                  ...controller.getTableWidgets(articleId, context),
                  SizedBox(height: AppSpacing.lg),
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
          fontSize: 14.sp,
          height: 1.85,
          color: colorScheme.onSurface.withValues(alpha: 0.88),
          fontFamily: 'Cairo',
        ),
        h1Padding: EdgeInsets.only(top: 20.h, bottom: 8.h),
        h2Padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
        h3Padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
        h1: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurface,
          fontFamily: 'Cairo',
          height: 1.4,
        ),
        h2: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          fontFamily: 'Cairo',
          height: 1.4,
        ),
        h3: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.accentLight : AppColors.accentColor,
          fontFamily: 'Cairo',
          height: 1.4,
        ),
        listBullet: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 14.sp,
        ),
        listIndent: 20.w,
        em: TextStyle(
          fontStyle: FontStyle.italic,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        strong: TextStyle(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        blockquote: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 13.sp,
          height: 1.7,
        ),
        blockquoteDecoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: isDark ? 0.1 : 0.06),
          borderRadius: AppDimens.borderSm,
        ),
        blockquotePadding: EdgeInsets.all(12.w),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
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
