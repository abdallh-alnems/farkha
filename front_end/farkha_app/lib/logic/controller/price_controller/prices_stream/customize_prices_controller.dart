import 'package:get/get.dart';

import '../../../../../core/class/status_request.dart';
import '../../../../../core/functions/handing_data_controller.dart';
import '../../../../../core/services/initialization.dart';
import '../../../../../data/data_source/remote/prices_data/types_data.dart';
import 'prices_stream_controller.dart';

class CustomizePricesController extends GetxController {
  final RxList<Map<String, dynamic>> priceTypes = <Map<String, dynamic>>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> categorizedTypes =
      <String, List<Map<String, dynamic>>>{}.obs;
  final Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  TypesData typesData = TypesData(Get.find());

  final MyServices _myServices = Get.find();
  static const String _selectedTypesKey = 'selected_price_types';

  @override
  void onInit() {
    super.onInit();
    getTypesData();
  }

  List<int> _loadSelectedTypes() {
    final savedTypes = _myServices.getStorage.read<List<dynamic>>(
      _selectedTypesKey,
    );

    if (savedTypes != null && savedTypes.isNotEmpty) {
      List<int> types = savedTypes.map((e) => int.parse(e.toString())).toList();
      if (!types.contains(1)) {
        types.add(1);
      }
      return types;
    } else {
      return [1, 7];
    }
  }

  Future<void> getTypesData() async {
    try {
      statusRequest.value = StatusRequest.loading;
      print('🔄 Loading types data...');

      var response = await typesData.getTypes();
      print('📡 API Response: $response');
      statusRequest.value = handlingData(response);
      print('📊 Status after handling: ${statusRequest.value}');

      if (StatusRequest.success == statusRequest.value) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == "success") {
          Map<String, dynamic> data = mapResponse['data'];
          print('📊 Data structure: ${data.runtimeType}');
          print('📊 Data keys: ${data.keys.toList()}');
          if (data.isNotEmpty) {
            List<int> selectedTypeIds = _loadSelectedTypes();
            List<Map<String, dynamic>> allTypes = [];

            // تحويل البيانات من Map إلى List مع إضافة main_name
            data.forEach((categoryName, typesList) {
              print('📊 Processing category: $categoryName');
              print('📊 Types list type: ${typesList.runtimeType}');
              if (typesList is List) {
                print('📊 Types list length: ${typesList.length}');
                for (var item in typesList) {
                  if (item is Map<String, dynamic>) {
                    int typeId = item['id'] ?? 0;
                    String typeName = item['name'] ?? '';
                    bool isSelected = selectedTypeIds.contains(typeId);

                    allTypes.add({
                      'id': typeId,
                      'name': typeName,
                      'main_name': categoryName,
                      'isSelected': isSelected,
                    });
                    print('📊 Added type: $typeName (ID: $typeId)');
                  }
                }
              }
            });

            priceTypes.value = allTypes;
            print('✅ Loaded ${allTypes.length} price types');
            print('✅ Categories: ${data.keys.toList()}');
            _categorizeTypes();
            _saveTypeNames();
          }
        } else {
          print('❌ API returned failure status: ${mapResponse['status']}');
          statusRequest.value = StatusRequest.failure;
        }
      } else {
        print('❌ Status request is not success: ${statusRequest.value}');
      }
    } catch (e) {
      print('❌ Error in getTypesData: $e');
      statusRequest.value = StatusRequest.failure;
    }
  }

  void _categorizeTypes() {
    Map<String, List<Map<String, dynamic>>> newCategorizedTypes = {};
    for (var item in priceTypes) {
      String category = item['main_name'] ?? 'أخرى';
      if (!newCategorizedTypes.containsKey(category)) {
        newCategorizedTypes[category] = [];
      }
      newCategorizedTypes[category]!.add(Map.from(item));
    }
    categorizedTypes.value = newCategorizedTypes;
    print('✅ Categorized types: ${categorizedTypes.keys.toList()}');
  }

  void toggleItemSelection(Map<String, dynamic> item) {
    if (item['id'] == 1 && item['isSelected'] == true) {
      return;
    }

    int mainIndex = priceTypes.indexWhere(
      (element) => element['id'] == item['id'],
    );
    if (mainIndex != -1) {
      List<Map<String, dynamic>> newList = [];
      for (int i = 0; i < priceTypes.length; i++) {
        if (i == mainIndex) {
          Map<String, dynamic> updatedItem = Map.from(priceTypes[i]);
          updatedItem['isSelected'] = !updatedItem['isSelected'];
          newList.add(updatedItem);
        } else {
          newList.add(Map.from(priceTypes[i]));
        }
      }

      priceTypes.value = newList;

      _categorizeTypes();

      _saveSelectedTypes();

      _updatePricesStreamController();
    }
  }

  void _saveSelectedTypes() {
    final selectedTypes =
        priceTypes
            .where((item) => item['isSelected'])
            .map((item) => item['id'] as int)
            .toList();

    if (!selectedTypes.contains(1)) {
      selectedTypes.add(1);
    }

    _myServices.getStorage.write(_selectedTypesKey, selectedTypes);
  }

  void _updatePricesStreamController() {
    final selectedTypes =
        priceTypes
            .where((item) => item['isSelected'])
            .map((item) => item['id'] as int)
            .toList();

    if (selectedTypes.isNotEmpty) {
      final controller = Get.find<PricesStreamController>();
      controller.updateSelectedTypeIds(selectedTypes);
    }
  }

  void _saveTypeNames() {
    Map<String, String> namesMap = {};
    for (var item in priceTypes) {
      int typeId = item['id'] as int;
      String typeName = item['name'] as String;
      namesMap[typeId.toString()] = typeName;
    }
    _myServices.getStorage.write('type_names', namesMap);
  }
}
