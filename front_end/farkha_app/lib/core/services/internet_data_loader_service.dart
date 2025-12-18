import 'package:get/get.dart';

import '../../logic/controller/price_controller/main_types_controller.dart';
import '../../logic/controller/price_controller/prices_by_type_controller.dart';
import '../../logic/controller/price_controller/prices_card/customize_prices_controller.dart';
import '../../logic/controller/price_controller/prices_card/prices_card_controller.dart';
import '../../logic/controller/tools_controller/feasibility_study_controller.dart';
import '../class/status_request.dart';

class InternetDataLoaderService {
  static Future<void> reloadCurrentPageData() async {
    final String currentRoute = Get.currentRoute;

    try {
      if (currentRoute == '/') {
        await _reloadHomePageData();
      } else if (currentRoute == '/mainTypes') {
        await _reloadMainTypesData();
      } else if (currentRoute == '/pricesByType') {
        await _reloadPricesByTypeData();
      } else if (currentRoute == '/customize-prices') {
        await _reloadCustomizePricesData();
      } else if (currentRoute == '/feasibilityStudy') {
        await _reloadFeasibilityStudyData();
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
      controller.mainTypesList.isEmpty,
    )) {
      await controller.getDataMainTypes();
    }
  }

  static Future<void> _reloadPricesByTypeData() async {
    if (!Get.isRegistered<PricesByTypeController>()) return;

    final controller = Get.find<PricesByTypeController>();
    if (_shouldReloadData(
      controller.statusRequest,
      controller.pricesByTypeList.isEmpty,
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

  static bool _shouldReloadData(StatusRequest statusRequest, bool isDataEmpty) {
    return statusRequest != StatusRequest.success || isDataEmpty;
  }
}