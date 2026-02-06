import 'dart:math';

import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/functions/handing_data_controller.dart';
import '../../../../data/data_source/remote/tools/articles_data.dart';

class ArticlesListController extends GetxController {
  late StatusRequest statusRequest;
  ArticlesData articlesData = ArticlesData(Get.find());
  List<Map<String, dynamic>> articlesList = [];

  @override
  void onInit() {
    super.onInit();
    getArticles();
  }

  Future<void> getArticles() async {
    statusRequest = StatusRequest.loading;
    update();
    final response = await articlesData.getArticlesList();
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      final mapResponse = response as Map<String, dynamic>;
      if (mapResponse['status'] == 'success') {
        final articles =
            (mapResponse['data'] as List).cast<Map<String, dynamic>>();
        articlesList = _shuffleArticles(articles);
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
}
