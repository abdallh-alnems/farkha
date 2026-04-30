import 'package:get/get.dart';
import '../../../data/data_source/remote/prices_data/prices_by_type.dart';
import '../base/base_list_controller.dart';

class PricesByTypeController extends BaseListController {
  PricesByTypeData pricesByTypesData = PricesByTypeData(Get.find());

  String? _currentMainId;

  @override
  Future<dynamic> fetchData() =>
      pricesByTypesData.getData(_currentMainId!);

  Future<void> getDataPricesByType(String mainId) async {
    _currentMainId = mainId;
    await load();
  }
}
