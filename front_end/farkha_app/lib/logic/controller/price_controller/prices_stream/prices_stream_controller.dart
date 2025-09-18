import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/id/api.dart';
import '../../../../core/functions/handing_data_controller.dart';
import '../../../../core/services/initialization.dart';
import '../../../../core/services/sse_service.dart';
import '../../../../data/data_source/remote/prices_data/prices_stream_data.dart';

class PricesStreamController extends GetxController {
  StatusRequest statusRequest = StatusRequest.loading;
  PricesStreamData pricesStreamData = PricesStreamData(Get.find());

  late SseService _sseService;
  StreamSubscription<Map<String, dynamic>>? _sseSubscription;
  Timer? _retryTimer;

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

  Future<void> startSseConnection() async {
    _sseService = Get.find<SseService>();

    _sseSubscription = _sseService.dataStream.listen(
      (data) {
        _handleSseData(data);
      },
      onError: (error) {
        _scheduleRetry();
      },
      onDone: () {
        _scheduleRetry();
      },
      cancelOnError: false,
    );

    final url = '${Api.pricesStream}?type_ids=${selectedTypeIds.join(',')}';
    await _sseService.connect(url);
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 30), () {
      startSseConnection();
    });
  }

  void _handleSseData(Map<String, dynamic> data) {
    if (data['status'] == "success" && data['data'] != null) {
      List responseData = data['data'];

      if (responseData.isNotEmpty) {
        for (var item in responseData) {
          int typeId = item['type_id'] ?? 0;
          if (typeId > 0) {
            pricesData[typeId] = {
              'higher_today': item['higher_today']?.toString() ?? '',
              'lower_today': item['lower_today']?.toString() ?? '',
              'higher_yesterday': item['higher_yesterday']?.toString() ?? '',
              'lower_yesterday': item['lower_yesterday']?.toString() ?? '',
            };

            if (item['type_name'] != null) {
              typeNames[typeId] = item['type_name'].toString();
            }
          }
        }

        statusRequest = StatusRequest.success;
        update();
      }
    }
  }

  Future<void> getDataPricesStream() async {
    try {
      statusRequest = StatusRequest.loading;
      update();

      var response = await pricesStreamData.getDataWithTypeIds(selectedTypeIds);
      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == "success") {
          List data = mapResponse['data'];
          if (data.isNotEmpty) {
            for (var item in data) {
              int typeId = item['type_id'] ?? 0;
              if (typeId > 0) {
                pricesData[typeId] = {
                  'higher_today': item['higher_today']?.toString() ?? '',
                  'lower_today': item['lower_today']?.toString() ?? '',
                  'higher_yesterday':
                      item['higher_yesterday']?.toString() ?? '',
                  'lower_yesterday': item['lower_yesterday']?.toString() ?? '',
                };

                if (item['type_name'] != null) {
                  typeNames[typeId] = item['type_name'].toString();
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

    _sseSubscription?.cancel();
    startSseConnection();

    update();
  }

  @override
  void onInit() {
    _loadSelectedTypes();
    _loadTypeNames();
    startSseConnection();
    super.onInit();
  }

  @override
  void onClose() {
    _retryTimer?.cancel();
    _sseSubscription?.cancel();
    super.onClose();
  }
}
