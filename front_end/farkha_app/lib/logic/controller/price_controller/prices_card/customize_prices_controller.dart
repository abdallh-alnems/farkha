import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../../core/class/status_request.dart';
import '../../../../../core/constant/storage_keys.dart';
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

  @override
  void onInit() {
    super.onInit();
    getTypesData();
    // Note: Subscription restoration is now handled by NotificationService.init()
  }

  List<int> _loadSelectedTypes() {
    final savedTypes = _myServices.getStorage.read<List<dynamic>>(
      StorageKeys.selectedPriceTypes,
    );

    if (savedTypes != null && savedTypes.isNotEmpty) {
      final List<int> types = savedTypes.map((e) => int.parse(e.toString())).toList();
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
      StorageKeys.notificationEnabledTypes,
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

      final response = await typesData.getTypes();
      statusRequest.value = handlingData(response);

      if (StatusRequest.success == statusRequest.value) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == 'success') {
          final Map<String, dynamic> data = mapResponse['data'] as Map<String, dynamic>;
          if (data.isNotEmpty) {
            final List<int> selectedTypeIds = _loadSelectedTypes();
            final List<String> notificationEnabledTopics =
                _loadNotificationEnabledTypes();
            final List<Map<String, dynamic>> allTypes = [];

            // تحويل البيانات من Map إلى List مع إضافة main_name
            data.forEach((categoryName, typesList) {
              if (typesList is List) {
                for (var item in typesList) {
                  if (item is Map<String, dynamic>) {
                    final int typeId = (item['id'] as num?)?.toInt() ?? 0;
                    final String typeName = (item['name'] ?? '').toString();
                    final bool isSelected = selectedTypeIds.contains(typeId);

                    // Check if notification is enabled for this type
                    final String? topicName = _getTopicNameFromId(typeId);
                    final bool isNotificationEnabled =
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
    final Map<String, List<Map<String, dynamic>>> newCategorizedTypes = {};
    for (var item in priceTypes) {
      final String category = (item['main_name'] ?? 'أخرى').toString();
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

    final int mainIndex = priceTypes.indexWhere(
      (element) => element['id'] == item['id'],
    );
    if (mainIndex != -1) {
      final List<Map<String, dynamic>> newList = [];
      for (int i = 0; i < priceTypes.length; i++) {
        if (i == mainIndex) {
          final Map<String, dynamic> updatedItem = Map.from(priceTypes[i]);
          updatedItem['isSelected'] = !((updatedItem['isSelected'] as bool?) ?? false);
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
    final String? topicName = item['topicName'] as String?;
    if (topicName == null) return;

    final int mainIndex = priceTypes.indexWhere(
      (element) => element['id'] == item['id'],
    );

    if (mainIndex != -1) {
      final List<Map<String, dynamic>> newList = [];
      for (int i = 0; i < priceTypes.length; i++) {
        if (i == mainIndex) {
          final Map<String, dynamic> updatedItem = Map.from(priceTypes[i]);
          final bool newNotificationState = !((updatedItem['isNotificationEnabled'] as bool?) ?? false);
          updatedItem['isNotificationEnabled'] = newNotificationState;

          // Subscribe or unsubscribe from topic (without await to avoid ANR)
          if (newNotificationState) {
            unawaited(
              NotificationService.instance.subscribeToTopic(topicName).catchError(
                (Object error) {
                  // Log error but don't block UI
                  debugPrint('Error subscribing to $topicName: $error');
                },
              ),
            );
          } else {
            unawaited(
              NotificationService.instance
                  .unsubscribeFromTopic(topicName)
                  .catchError((Object error) {
                    // Log error but don't block UI
                    debugPrint('Error unsubscribing from $topicName: $error');
                  }),
            );
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
      StorageKeys.notificationEnabledTypes,
      notificationEnabledTopics,
    );
  }

  void _saveSelectedTypes() {
    final selectedTypes =
        priceTypes
            .where((item) => (item['isSelected'] as bool?) ?? false)
            .map((item) => (item['id'] as num).toInt())
            .toList();

    if (!selectedTypes.contains(1)) {
      selectedTypes.add(1);
    }

    _myServices.getStorage.write(StorageKeys.selectedPriceTypes, selectedTypes);
  }

  void _updatePricesCardController() {
    final selectedTypes =
        priceTypes
            .where((item) => (item['isSelected'] as bool?) ?? false)
            .map((item) => (item['id'] as num).toInt())
            .toList();

    if (selectedTypes.isNotEmpty) {
      final controller = Get.find<PricesCardController>();
      controller.updateSelectedTypeIds(selectedTypes);
    }
  }

  void _saveTypeNames() {
    final Map<String, String> namesMap = {};
    for (var item in priceTypes) {
      final int typeId = item['id'] as int;
      final String typeName = item['name'] as String;
      namesMap[typeId.toString()] = typeName;
    }
    _myServices.getStorage.write(StorageKeys.typeNames, namesMap);
  }
}
