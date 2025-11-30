import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/routes/route.dart';
import '../../../../core/shared/action_button.dart';
import '../../../../logic/controller/tools_controller/articles_controller/articles_list_controller.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/ad/native.dart';
import '../../../widget/appbar/custom_appbar.dart';

class ArticlesList extends StatelessWidget {
  const ArticlesList({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ArticlesListController());

    return Scaffold(
      appBar: const CustomAppBar(text: 'مقالات'),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<ArticlesListController>(
              builder: (controller) {
                return HandlingDataView(
                  statusRequest: controller.statusRequest,
                  widget: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 11),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 19),
                          child: AdNativeWidget(),
                        ),
                        ...controller.articlesList.map(
                          (article) => ActionButton(
                            text: article['title'],
                            onTap:
                                () => Get.toNamed(
                                  AppRoute.articleDetail,
                                  arguments: {
                                    'id': article['id'],
                                    'title': article['title'],
                                  },
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
