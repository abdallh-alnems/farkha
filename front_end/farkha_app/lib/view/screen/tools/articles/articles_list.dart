import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/routes/route.dart';
import '../../../../core/functions/tool_page_view.dart';
import '../../../../logic/controller/tools_controller/articles_controller/articles_list_controller.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/ad/native.dart';
import '../../../widget/appbar/custom_appbar.dart';
import 'article_card.dart';

class ArticlesList extends StatelessWidget {
  const ArticlesList({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ArticlesListController());

    logToolPageViewOnce(widgetType: ArticlesList, toolId: 11);

    return Scaffold(
      appBar: const CustomAppBar(text: 'مقالات', favoriteToolName: 'مقالات'),
      body: GetBuilder<ArticlesListController>(
        builder: (controller) {
          return HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: AdNativeWidget()),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final article = controller.items[index];
                        return ArticleCard(
                          title: (article['title'] ?? '').toString(),
                          onTap: () => Get.toNamed<void>(
                            AppRoute.articleDetail,
                            arguments: {
                              'id': article['id'],
                              'title': article['title'],
                            },
                          ),
                        );
                      },
                      childCount: controller.items.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
