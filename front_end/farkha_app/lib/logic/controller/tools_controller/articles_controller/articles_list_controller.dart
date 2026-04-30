import 'dart:math';

import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/functions/handling_data_controller.dart';
import '../../../../data/data_source/remote/tools/articles_data.dart';
import '../../base/base_list_controller.dart';

class ArticlesListController extends BaseListController {
  ArticlesData articlesData = ArticlesData(Get.find());

  @override
  Future<dynamic> fetchData() => articlesData.getArticlesList();

  @override
  Future<void> load() async {
    statusRequest = StatusRequest.loading;
    update();

    final response = await fetchData();
    statusRequest = handlingData(response);

    if (statusRequest == StatusRequest.success) {
      final mapResponse = response as Map<String, dynamic>;
      if (mapResponse['status'] == 'success') {
        final articles =
            (mapResponse['data'] as List).cast<Map<String, dynamic>>();
        items = _shuffleArticles(articles);
      } else {
        statusRequest = StatusRequest.failure;
      }
    }

    update();
  }

  List<Map<String, dynamic>> _shuffleArticles(
    List<Map<String, dynamic>> articles,
  ) {
    final shuffledList = List<Map<String, dynamic>>.from(articles);
    final random = Random();

    for (int i = shuffledList.length - 1; i > 0; i--) {
      final int j = random.nextInt(i + 1);
      final temp = shuffledList[i];
      shuffledList[i] = shuffledList[j];
      shuffledList[j] = temp;
    }

    return shuffledList;
  }

  @override
  void onInit() {
    load();
    super.onInit();
  }
}
