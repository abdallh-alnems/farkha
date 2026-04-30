import 'package:get/get.dart';

import '../../logic/controller/cycle_controller.dart';
import '../../logic/controller/price_controller/main_types_controller.dart';
import '../../logic/controller/price_controller/prices_by_type_controller.dart';
import '../../logic/controller/price_controller/prices_card/customize_prices_controller.dart';
import '../../logic/controller/price_controller/prices_card/prices_card_controller.dart';
import '../../logic/controller/tools_controller/articles_controller/article_detail_controller.dart';
import '../../logic/controller/tools_controller/articles_controller/articles_list_controller.dart';
import '../../logic/controller/tools_controller/broiler_controller.dart';
import '../../logic/controller/tools_controller/feasibility_study_controller.dart';
import '../class/status_request.dart';
import '../constant/routes/route.dart';

class InternetDataLoaderService {
  static Future<void> reloadCurrentPageData() async {
    final String currentRoute = Get.currentRoute;

    try {
      if (currentRoute == '/') {
        await _reloadHomePageData();
      } else if (currentRoute == AppRoute.mainTypes) {
        await _reloadMainTypesData();
      } else if (currentRoute == AppRoute.pricesByType) {
        await _reloadPricesByTypeData();
      } else if (currentRoute == AppRoute.customizePrices) {
        await _reloadCustomizePricesData();
      } else if (currentRoute == AppRoute.feasibilityStudy) {
        await _reloadFeasibilityStudyData();
      } else if (currentRoute == AppRoute.articlesList) {
        await _reloadArticlesListData();
      } else if (currentRoute == AppRoute.articleDetail) {
        await _reloadArticleDetailData();
      } else if (currentRoute == AppRoute.broilerChickenRequirements) {
        await _reloadBroilerData();
      } else if (currentRoute == AppRoute.cycle) {
        await _reloadCycleList();
        await _reloadCycleDetails();
      } else if (currentRoute == AppRoute.cycleData ||
          currentRoute == AppRoute.cycleExpenses) {
        await _reloadCycleDetails();
      }
    } catch (_) {}
  }

  static Future<void> _reloadHomePageData() async {
    if (!Get.isRegistered<PricesCardController>()) return;

    final controller = Get.find<PricesCardController>();
    if (_shouldReloadData(
      controller.statusRequest,
      controller.pricesData.isEmpty,
    )) {
      await controller.getDataPricesCard();
    }
  }

  static Future<void> _reloadMainTypesData() async {
    if (!Get.isRegistered<MainTypesController>()) return;

    final controller = Get.find<MainTypesController>();
    if (_shouldReloadData(
      controller.statusRequest,
      controller.items.isEmpty,
    )) {
      await controller.load();
    }
  }

  static Future<void> _reloadPricesByTypeData() async {
    if (!Get.isRegistered<PricesByTypeController>()) return;

    final controller = Get.find<PricesByTypeController>();
    if (_shouldReloadData(
      controller.statusRequest,
      controller.items.isEmpty,
    )) {
      if (Get.arguments != null && Get.arguments['main_id'] != null) {
        final String mainId = Get.arguments['main_id'].toString();
        await controller.getDataPricesByType(mainId);
      }
    }
  }

  static Future<void> _reloadCustomizePricesData() async {
    if (!Get.isRegistered<CustomizePricesController>()) return;

    final controller = Get.find<CustomizePricesController>();
    if (_shouldReloadData(
      controller.statusRequest.value,
      controller.priceTypes.isEmpty,
    )) {
      await controller.getTypesData();
    }
  }

  static Future<void> _reloadFeasibilityStudyData() async {
    if (!Get.isRegistered<FeasibilityController>()) return;

    final controller = Get.find<FeasibilityController>();
    if (controller.pricesStatusRequest.value != StatusRequest.success) {
      await controller.fetchFeasibilityData();
    }
  }

  static Future<void> _reloadArticlesListData() async {
    if (!Get.isRegistered<ArticlesListController>()) return;

    final controller = Get.find<ArticlesListController>();
    if (_shouldReloadData(
      controller.statusRequest,
      controller.items.isEmpty,
    )) {
      await controller.load();
    }
  }

  static Future<void> _reloadArticleDetailData() async {
    if (!Get.isRegistered<ArticleDetailController>()) return;

    final controller = Get.find<ArticleDetailController>();
    if (_shouldReloadData(
      controller.statusRequest,
      controller.articleData.isEmpty,
    )) {
      if (Get.arguments != null && Get.arguments['id'] != null) {
        final String articleId = Get.arguments['id'].toString();
        await controller.getArticleDetail(articleId);
      }
    }
  }

  static Future<void> _reloadBroilerData() async {
    if (!Get.isRegistered<BroilerController>()) return;

    final controller = Get.find<BroilerController>();
    await controller.fetchBroilerPrice();
    controller.refreshWeatherTemperature();
  }

  static Future<void> _reloadCycleList() async {
    if (!Get.isRegistered<CycleController>()) return;

    final controller = Get.find<CycleController>();
    await controller.fetchCyclesFromServer();
  }

  static Future<void> _reloadCycleDetails() async {
    if (!Get.isRegistered<CycleController>()) return;

    final controller = Get.find<CycleController>();
    final cycleId = controller.currentCycle['cycle_id'];

    if (cycleId != null) {
      final int? id = int.tryParse(cycleId.toString());
      if (id != null) {
        await controller.fetchCycleDetails(id);
      }
    }
  }

  static bool _shouldReloadData(StatusRequest statusRequest, bool isDataEmpty) {
    return statusRequest != StatusRequest.success || isDataEmpty;
  }
}
