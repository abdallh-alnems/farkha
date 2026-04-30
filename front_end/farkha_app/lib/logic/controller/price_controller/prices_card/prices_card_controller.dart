import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/storage_keys.dart';
import '../../../../core/functions/handling_data_controller.dart';
import '../../../../core/services/initialization.dart';
import '../../../../data/data_source/remote/prices_data/prices_card_data.dart';

class PricesCardController extends GetxController {
  StatusRequest statusRequest = StatusRequest.loading;
  PricesCardData pricesCardData = PricesCardData(Get.find());

  final MyServices _myServices = Get.find();

  final RxList<int> selectedTypeIds = <int>[1, 7].obs;

  Map<int, Map<String, String>> pricesData = {};
  Map<int, String> typeNames = {};

  // حماية من الطلبات المتزامنة
  bool _isLoading = false;

  // التحديث الدوري
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(minutes: 10);

  // Caching مع TTL
  DateTime? _lastFetchTime;
  static const Duration _minFetchInterval = Duration(minutes: 2);

  // آخر تحديث ناجح
  DateTime? lastUpdated;

  String getTypeName(int typeId) {
    return typeNames[typeId] ?? 'نوع $typeId';
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
    final double higher =
        double.tryParse(prices['higher_yesterday'] ?? '') ?? 0;
    final double lower = double.tryParse(prices['lower_yesterday'] ?? '') ?? 0;
    return (higher + lower) / 2;
  }

  double getTypeTodayAverage(int typeId) {
    final prices = getTypePrices(typeId);
    final double higher = double.tryParse(prices['higher_today'] ?? '') ?? 0;
    final double lower = double.tryParse(prices['lower_today'] ?? '') ?? 0;
    return (higher + lower) / 2;
  }

  double getTypePriceDifference(int typeId) {
    return getTypeTodayAverage(typeId) - getTypeYesterdayAverage(typeId);
  }

  // دالة مشتركة لتحويل بيانات الاستجابة (DRY)
  void _parseResponseData(List<dynamic> data) {
    for (var item in data) {
      final int typeId = (item['id'] as num?)?.toInt() ?? 0;
      if (typeId > 0) {
        pricesData[typeId] = {
          'higher_today': item['higher_today']?.toString() ?? '',
          'lower_today': item['lower_today']?.toString() ?? '',
          'higher_yesterday': item['higher_yesterday']?.toString() ?? '',
          'lower_yesterday': item['lower_yesterday']?.toString() ?? '',
        };

        if (item['name'] != null) {
          typeNames[typeId] = item['name'].toString();
        }
      }
    }
    lastUpdated = DateTime.now();
  }

  void _loadSelectedTypes() {
    final savedTypes = _myServices.getStorage.read<List<dynamic>>(
      StorageKeys.selectedPriceTypes,
    );

    if (savedTypes != null && savedTypes.isNotEmpty) {
      final List<int> types =
          savedTypes.map((e) => int.parse(e.toString())).toList();
      if (!types.contains(1)) {
        types.add(1);
      }
      selectedTypeIds.assignAll(types);
    } else {
      selectedTypeIds.assignAll([1, 7]);
    }
  }

  void _saveSelectedTypes() {
    final List<int> types = List.from(selectedTypeIds);
    if (!types.contains(1)) {
      types.add(1);
    }
    _myServices.getStorage.write(StorageKeys.selectedPriceTypes, types);
  }

  void _loadTypeNames() {
    final savedNames = _myServices.getStorage.read<Map<String, dynamic>>(
      StorageKeys.typeNames,
    );
    if (savedNames != null) {
      typeNames = savedNames.map(
        (key, value) => MapEntry(int.parse(key), value.toString()),
      );
    }
  }

  Future<void> getDataPricesCard() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      statusRequest = StatusRequest.loading;
      update();

      final response = await pricesCardData.getDataWithTypeIds(selectedTypeIds);
      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == 'success') {
          final List<dynamic> data = mapResponse['data'] as List<dynamic>;
          if (data.isNotEmpty) {
            _parseResponseData(data);
          }
        } else {
          statusRequest = StatusRequest.failure;
        }
      }
    } catch (e) {
      statusRequest = StatusRequest.failure;
      debugPrint('PricesCardController.getDataPricesCard error: $e');
    } finally {
      _isLoading = false;
      _lastFetchTime = DateTime.now();
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
    // تجاهل التحديث إذا لم تمر المدة الكافية
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _minFetchInterval) {
      return;
    }

    if (_isLoading) return;
    _isLoading = true;

    try {
      // تحديث البيانات بدون تغيير حالة التحميل
      final response = await pricesCardData.getDataWithTypeIds(selectedTypeIds);
      final status = handlingData(response);

      if (StatusRequest.success == status) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == 'success') {
          final List<dynamic> data = mapResponse['data'] as List<dynamic>;
          if (data.isNotEmpty) {
            _parseResponseData(data);
          }
        }
      }
      // تحديث الواجهة بدون تغيير حالة التحميل
      update();
    } catch (e) {
      debugPrint('PricesCardController.refreshData error: $e');
    } finally {
      _isLoading = false;
      _lastFetchTime = DateTime.now();
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      refreshData();
    });
  }

  @override
  void onInit() {
    _loadSelectedTypes();
    _loadTypeNames();
    getDataPricesCard();
    _startPeriodicRefresh();
    super.onInit();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}
