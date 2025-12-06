import 'package:get/get.dart';

import '../../../../../core/class/status_request.dart';
import '../../../../../core/functions/handing_data_controller.dart';
import '../../../../../core/services/initialization.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../data/data_source/remote/prices_data/types_data.dart';
import '../../../../core/constant/id/notification_topics.dart';
import 'prices_card_controller.dart';

class CustomizePricesController extends GetxController {
  final RxList<Map<String, dynamic>> priceTypes = <Map<String, dynamic>>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> categorizedTypes =
      <String, List<Map<String, dynamic>>>{}.obs;
  final Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  TypesData typesData = TypesData(Get.find());

  final MyServices _myServices = Get.find();
  static const String _selectedTypesKey = 'selected_price_types';
  static const String _notificationTypesKey = 'notification_enabled_types';

  @override
  void onInit() {
    super.onInit();
    getTypesData();
    // Note: Subscription restoration is now handled by NotificationService.init()
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

  List<String> _loadNotificationEnabledTypes() {
    final savedNotifications = _myServices.getStorage.read<List<dynamic>>(
      _notificationTypesKey,
    );

    if (savedNotifications != null && savedNotifications.isNotEmpty) {
      return savedNotifications.map((e) => e.toString()).toList();
    } else {
      // افتراضياً: فقط lhm_abyad مفعّل
      return ['lhm_abyad'];
    }
  }

  // Helper: Get topic name from type ID
  String? _getTopicNameFromId(int id) {
    // Map type ID to topic name from notification_topics
    if (id >= 1 && id <= notificationTopics.length) {
      return notificationTopics[id - 1];
    }
    return null;
  }

  Future<void> getTypesData() async {
    try {
      statusRequest.value = StatusRequest.loading;

      var response = await typesData.getTypes();
      statusRequest.value = handlingData(response);

      if (StatusRequest.success == statusRequest.value) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == "success") {
          Map<String, dynamic> data = mapResponse['data'];
          if (data.isNotEmpty) {
            List<int> selectedTypeIds = _loadSelectedTypes();
            List<String> notificationEnabledTopics =
                _loadNotificationEnabledTypes();
            List<Map<String, dynamic>> allTypes = [];

            // تحويل البيانات من Map إلى List مع إضافة main_name
            data.forEach((categoryName, typesList) {
              if (typesList is List) {
                for (var item in typesList) {
                  if (item is Map<String, dynamic>) {
                    int typeId = item['id'] ?? 0;
                    String typeName = item['name'] ?? '';
                    bool isSelected = selectedTypeIds.contains(typeId);

                    // Check if notification is enabled for this type
                    String? topicName = _getTopicNameFromId(typeId);
                    bool isNotificationEnabled =
                        topicName != null &&
                        notificationEnabledTopics.contains(topicName);

                    allTypes.add({
                      'id': typeId,
                      'name': typeName,
                      'main_name': categoryName,
                      'isSelected': isSelected,
                      'isNotificationEnabled': isNotificationEnabled,
                      'topicName': topicName,
                    });
                  }
                }
              }
            });

            priceTypes.value = allTypes;
            _categorizeTypes();
            _saveTypeNames();
          }
        } else {
          statusRequest.value = StatusRequest.failure;
        }
      }
    } catch (_) {
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

      _updatePricesCardController();
    }
  }

  Future<void> toggleNotification(Map<String, dynamic> item) async {
    String? topicName = item['topicName'];
    if (topicName == null) return;

    int mainIndex = priceTypes.indexWhere(
      (element) => element['id'] == item['id'],
    );

    if (mainIndex != -1) {
      List<Map<String, dynamic>> newList = [];
      for (int i = 0; i < priceTypes.length; i++) {
        if (i == mainIndex) {
          Map<String, dynamic> updatedItem = Map.from(priceTypes[i]);
          bool newNotificationState = !updatedItem['isNotificationEnabled'];
          updatedItem['isNotificationEnabled'] = newNotificationState;

          // Subscribe or unsubscribe from topic
          if (newNotificationState) {
            await NotificationService.instance.subscribeToTopic(topicName);
          } else {
            await NotificationService.instance.unsubscribeFromTopic(topicName);
          }

          newList.add(updatedItem);
        } else {
          newList.add(Map.from(priceTypes[i]));
        }
      }

      priceTypes.value = newList;
      _categorizeTypes();
      _saveNotificationEnabledTypes();
    }
  }

  void _saveNotificationEnabledTypes() {
    final notificationEnabledTopics =
        priceTypes
            .where(
              (item) =>
                  item['isNotificationEnabled'] == true &&
                  item['topicName'] != null,
            )
            .map((item) => item['topicName'] as String)
            .toList();

    _myServices.getStorage.write(
      _notificationTypesKey,
      notificationEnabledTopics,
    );
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

  void _updatePricesCardController() {
    final selectedTypes =
        priceTypes
            .where((item) => item['isSelected'])
            .map((item) => item['id'] as int)
            .toList();

    if (selectedTypes.isNotEmpty) {
      final controller = Get.find<PricesCardController>();
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
