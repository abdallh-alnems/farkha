import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/functions/handing_data_controller.dart';
import '../../../../core/services/initialization.dart';
import '../../../../data/data_source/remote/prices_data/prices_card_data.dart';

class PricesCardController extends GetxController {
  StatusRequest statusRequest = StatusRequest.loading;
  PricesCardData pricesCardData = PricesCardData(Get.find());

  final MyServices _myServices = Get.find();
  static const String _selectedTypesKey = 'selected_price_types';

  final RxList<int> selectedTypeIds = <int>[1, 7].obs;

  Map<int, Map<String, String>> pricesData = {};
  Map<int, String> typeNames = {};

  String getTypeName(int typeId) {
    return typeNames[typeId] ?? "نوع $typeId";
  }

  Map<String, String> getTypePrices(int typeId) {
    return pricesData[typeId] ??
        {
          'higher_today': '',
          'lower_today': '',
          'higher_yesterday': '',
          'lower_yesterday': '',
        };
  }

  double getTypeYesterdayAverage(int typeId) {
    final prices = getTypePrices(typeId);
    double higher = double.tryParse(prices['higher_yesterday'] ?? '') ?? 0;
    double lower = double.tryParse(prices['lower_yesterday'] ?? '') ?? 0;
    return (higher + lower) / 2;
  }

  double getTypeTodayAverage(int typeId) {
    final prices = getTypePrices(typeId);
    double higher = double.tryParse(prices['higher_today'] ?? '') ?? 0;
    double lower = double.tryParse(prices['lower_today'] ?? '') ?? 0;
    return (higher + lower) / 2;
  }

  double getTypePriceDifference(int typeId) {
    return getTypeTodayAverage(typeId) - getTypeYesterdayAverage(typeId);
  }

  void _loadSelectedTypes() {
    final savedTypes = _myServices.getStorage.read<List<dynamic>>(
      _selectedTypesKey,
    );

    if (savedTypes != null && savedTypes.isNotEmpty) {
      List<int> types = savedTypes.map((e) => int.parse(e.toString())).toList();
      if (!types.contains(1)) {
        types.add(1);
      }
      selectedTypeIds.assignAll(types);
    } else {
      selectedTypeIds.assignAll([1, 7]);
    }
  }

  void _saveSelectedTypes() {
    List<int> types = List.from(selectedTypeIds);
    if (!types.contains(1)) {
      types.add(1);
    }
    _myServices.getStorage.write(_selectedTypesKey, types);
  }

  void _loadTypeNames() {
    final savedNames = _myServices.getStorage.read<Map<String, dynamic>>(
      'type_names',
    );
    if (savedNames != null) {
      typeNames = savedNames.map(
        (key, value) => MapEntry(int.parse(key), value.toString()),
      );
    }
  }

  Future<void> getDataPricesCard() async {
    try {
      statusRequest = StatusRequest.loading;
      update();

      var response = await pricesCardData.getDataWithTypeIds(selectedTypeIds);
      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == "success") {
          List data = mapResponse['data'];
          if (data.isNotEmpty) {
            for (var item in data) {
              int typeId = item['id'] ?? 0;
              if (typeId > 0) {
                pricesData[typeId] = {
                  'higher_today': item['higher_today']?.toString() ?? '',
                  'lower_today': item['lower_today']?.toString() ?? '',
                  'higher_yesterday':
                      item['higher_yesterday']?.toString() ?? '',
                  'lower_yesterday': item['lower_yesterday']?.toString() ?? '',
                };

                if (item['name'] != null) {
                  typeNames[typeId] = item['name'].toString();
                }
              }
            }
          }
        } else {
          statusRequest = StatusRequest.failure;
        }
      }
    } catch (e) {
      statusRequest = StatusRequest.failure;
    }
    update();
  }

  void updateSelectedTypeIds(List<int> newTypeIds) {
    if (!newTypeIds.contains(1)) {
      newTypeIds.add(1);
    }

    selectedTypeIds.value = newTypeIds;

    _saveSelectedTypes();

    // إعادة تحميل البيانات عند تغيير الأنواع المحددة
    getDataPricesCard();

    update();
  }

  // دالة لإعادة تحديث البيانات عند العودة للتطبيق (بدون إظهار التحميل)
  Future<void> refreshData() async {
    try {
      // تحديث البيانات بدون تغيير حالة التحميل
      var response = await pricesCardData.getDataWithTypeIds(selectedTypeIds);
      final status = handlingData(response);

      if (StatusRequest.success == status) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == "success") {
          List data = mapResponse['data'];
          if (data.isNotEmpty) {
            for (var item in data) {
              int typeId = item['id'] ?? 0;
              if (typeId > 0) {
                pricesData[typeId] = {
                  'higher_today': item['higher_today']?.toString() ?? '',
                  'lower_today': item['lower_today']?.toString() ?? '',
                  'higher_yesterday':
                      item['higher_yesterday']?.toString() ?? '',
                  'lower_yesterday': item['lower_yesterday']?.toString() ?? '',
                };

                if (item['name'] != null) {
                  typeNames[typeId] = item['name'].toString();
                }
              }
            }
          }
        }
      }
      // تحديث الواجهة بدون تغيير حالة التحميل
      update();
    } catch (e) {
      // في حالة الخطأ، لا نغير حالة التحميل
      // يمكن إضافة معالجة الأخطاء هنا إذا لزم الأمر
    }
  }

  @override
  void onInit() {
    _loadSelectedTypes();
    _loadTypeNames();
    getDataPricesCard();
    super.onInit();
  }
}
