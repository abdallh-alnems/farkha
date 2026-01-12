import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/services/initialization.dart';
import '../../data/data_source/remote/cycle_data/cycle_data.dart';
import 'cycle_controller.dart';

class CustomDataEntry {
  final String id;
  final String text;
  final DateTime date;

  CustomDataEntry({required this.id, required this.text, required this.date});

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'date': date.toIso8601String()};
  }

  factory CustomDataEntry.fromJson(Map<String, dynamic> json) {
    return CustomDataEntry(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}

class CustomDataItem {
  final String id;
  final String label;
  final IconData icon;
  final RxList<CustomDataEntry> entries;

  // Map للأيقونات الشائعة - const للسماح لـ tree-shaking بالعمل
  static const Map<String, IconData> _iconMap = {
    'note': Icons.note,
    'receipt': Icons.receipt,
    'grain': Icons.grain,
    'medication': Icons.medication,
    'bolt': Icons.bolt,
    'water_drop': Icons.water_drop,
    'local_shipping': Icons.local_shipping,
    'people': Icons.people,
  };

  CustomDataItem({
    required this.id,
    required this.label,
    required this.icon,
    List<CustomDataEntry>? entries,
  }) : entries = (entries ?? <CustomDataEntry>[]).obs;

  // Helper method للحصول على اسم الأيقونة من IconData
  static String _getIconName(IconData icon) {
    for (final entry in _iconMap.entries) {
      if (entry.value.codePoint == icon.codePoint) {
        return entry.key;
      }
    }
    return 'note'; // افتراضي
  }

  // Helper method للحصول على IconData من اسم الأيقونة
  static IconData _getIconFromName(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.note; // أيقونة افتراضية
    }
    return _iconMap[iconName] ?? Icons.note;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': _getIconName(icon), // حفظ اسم الأيقونة بدلاً من codePoint
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  factory CustomDataItem.fromJson(Map<String, dynamic> json) {
    final entriesList =
        (json['entries'] as List<dynamic>?)
            ?.map((e) => CustomDataEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <CustomDataEntry>[];

    // دعم البيانات القديمة (codePoint) والجديدة (icon name)
    final iconValue = json['icon'];
    IconData iconData;

    if (iconValue is String) {
      // البيانات الجديدة: اسم الأيقونة
      iconData = _getIconFromName(iconValue);
    } else if (iconValue is int) {
      // البيانات القديمة: codePoint - نحولها إلى أيقونة افتراضية
      iconData = Icons.note;
    } else {
      // قيمة غير معروفة - أيقونة افتراضية
      iconData = Icons.note;
    }

    return CustomDataItem(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      icon: iconData,
      entries: entriesList,
    );
  }
}

class CycleCustomDataController extends GetxController {
  final GetStorage _storage = GetStorage();
  final RxList<CustomDataItem> customDataItems = <CustomDataItem>[].obs;
  late final CycleData _cycleData;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MyServices myServices = Get.find<MyServices>();

  String? _lastCycleId;

  @override
  void onInit() {
    super.onInit();
    _cycleData = CycleData();
    _loadSavedCustomData();
    _updateLastCycleId();

    final cycleCtrl = Get.find<CycleController>();
    ever(cycleCtrl.currentCycle, (_) {
      _checkAndReloadCustomData();
    });
  }

  void _updateLastCycleId() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    _lastCycleId = cycle['name'] ?? 'default';
  }

  void _checkAndReloadCustomData() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final currentCycleId = cycle['name'] ?? 'default';

    if (_lastCycleId != currentCycleId) {
      _lastCycleId = currentCycleId;
      _reloadCustomDataForCurrentCycle();
    }
  }

  void _reloadCustomDataForCurrentCycle() {
    customDataItems.clear();
    _loadSavedCustomData();
  }

  void loadCustomDataFromApi(List<dynamic> customDataEntries) {
    // تجميع البيانات المخصصة حسب label
    final dataMap = <String, List<Map<String, dynamic>>>{};

    for (var entry in customDataEntries) {
      final label = entry['label']?.toString() ?? '';
      final value = entry['value']?.toString() ?? '';
      final entryDateStr = entry['entry_date']?.toString() ?? '';

      if (label.isEmpty || value.isEmpty) continue;

      DateTime entryDate = DateTime.now();
      if (entryDateStr.isNotEmpty) {
        try {
          entryDate = DateTime.tryParse(entryDateStr) ?? DateTime.now();
        } catch (e) {
          entryDate = DateTime.now();
        }
      }

      if (!dataMap.containsKey(label)) {
        dataMap[label] = [];
      }
      dataMap[label]!.add({
        'id':
            entry['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'text': value,
        'date': entryDate.toIso8601String(),
      });
    }

    // تحديث أو إنشاء CustomDataItems
    for (var entry in dataMap.entries) {
      final label = entry.key;
      final entries = entry.value;

      // البحث عن item موجود بنفس label
      final existingIndex = customDataItems.indexWhere(
        (item) => item.label == label,
      );

      if (existingIndex != -1) {
        // تحديث entries للـ item الموجود
        final existingEntries =
            entries
                .map(
                  (e) => CustomDataEntry(
                    id: e['id'] as String,
                    text: e['text'] as String,
                    date:
                        DateTime.tryParse(e['date'] as String) ??
                        DateTime.now(),
                  ),
                )
                .toList();
        customDataItems[existingIndex].entries.clear();
        customDataItems[existingIndex].entries.addAll(existingEntries);
      } else {
        // إنشاء item جديد
        final newItem = CustomDataItem(
          id: 'api_${label}_${DateTime.now().millisecondsSinceEpoch}',
          label: label,
          icon: CustomDataItem._getIconFromName('note'),
          entries:
              entries
                  .map(
                    (e) => CustomDataEntry(
                      id: e['id'] as String,
                      text: e['text'] as String,
                      date:
                          DateTime.tryParse(e['date'] as String) ??
                          DateTime.now(),
                    ),
                  )
                  .toList(),
        );
        customDataItems.add(newItem);
      }
    }

    _saveCustomData();
  }

  void _loadSavedCustomData() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final cycleId = cycle['name'] ?? 'default';
    final storageKey = 'custom_data_$cycleId';

    // التحقق من أن الدورة موجودة فعلاً في cycles (لم يتم حذفها)
    final cycleExists = cycleCtrl.cycles.any((c) => c['name'] == cycleId);
    if (!cycleExists) {
      // إذا لم تكن الدورة موجودة، لا تحمل البيانات القديمة
      customDataItems.clear();
      return;
    }

    final saved = _storage.read<List>(storageKey);
    if (saved != null && saved.isNotEmpty && cycleExists) {
      final savedItems =
          saved
              .map((e) => CustomDataItem.fromJson(e as Map<String, dynamic>))
              .toList();

      customDataItems.clear();
      customDataItems.addAll(savedItems);
    }
  }

  void _saveCustomData() {
    final cycleCtrl = Get.find<CycleController>();
    final cycle = cycleCtrl.currentCycle;
    final cycleId = cycle['name'] ?? 'default';
    final storageKey = 'custom_data_$cycleId';

    final itemsJson = customDataItems.map((e) => e.toJson()).toList();
    _storage.write(storageKey, itemsJson);
  }

  Future<void> _sendCustomDataToServer({
    required String label,
    required String value,
  }) async {
    try {
      final cycleCtrl = Get.find<CycleController>();
      final cycleId = cycleCtrl.currentCycle['cycle_id'];
      if (cycleId == null) return;

      final isLoggedIn =
          myServices.getStorage.read<bool>('is_logged_in') ?? false;
      if (!isLoggedIn) return;

      final user = _auth.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      await _cycleData.addCycleData(
        token: token,
        cycleId:
            cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0,
        label: label,
        value: value,
      );
    } catch (e) {
      // في حالة الفشل، لا نفعل شيئاً - البيانات محفوظة محلياً
    }
  }

  Future<void> addEntry(int itemIndex, String text) async {
    if (itemIndex >= 0 &&
        itemIndex < customDataItems.length &&
        text.isNotEmpty) {
      final now = DateTime.now();
      final entry = CustomDataEntry(
        id: 'entry_${now.millisecondsSinceEpoch}',
        text: text,
        date: now,
      );
      customDataItems[itemIndex].entries.add(entry);
      _saveCustomData();

      // إرسال البيانات إلى API
      await _sendCustomDataToServer(
        label: customDataItems[itemIndex].label,
        value: text,
      );
    }
  }

  Future<void> removeEntry(int itemIndex, int entryIndex) async {
    if (itemIndex >= 0 &&
        itemIndex < customDataItems.length &&
        entryIndex >= 0 &&
        entryIndex < customDataItems[itemIndex].entries.length) {
      // الحذف المحلي فوراً
      final entry = customDataItems[itemIndex].entries[entryIndex];
      customDataItems[itemIndex].entries.removeAt(entryIndex);
      _saveCustomData();

      // حذف من API في الخلفية
      final cycleCtrl = Get.find<CycleController>();
      final cycleId = cycleCtrl.currentCycle['cycle_id'];
      final itemId = int.tryParse(entry.id);

      if (itemId != null && itemId > 0 && cycleId != null) {
        _deleteCustomDataFromServerInBackground(
          cycleId: cycleId,
          itemId: itemId,
        );
      }
    }
  }

  void addCustomDataItem(String label, IconData icon) {
    final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    customDataItems.add(CustomDataItem(id: newId, label: label, icon: icon));
    _saveCustomData();
  }

  Future<void> removeCustomDataItem(int index) async {
    if (index >= 0 && index < customDataItems.length) {
      // الحذف المحلي فوراً
      final item = customDataItems[index];
      customDataItems.removeAt(index);
      _saveCustomData();

      // حذف من API في الخلفية
      final cycleCtrl = Get.find<CycleController>();
      final cycleId = cycleCtrl.currentCycle['cycle_id'];

      if (cycleId != null) {
        _deleteCustomDataFromServerInBackground(
          cycleId: cycleId,
          label: item.label,
        );
      }
    }
  }

  void _deleteCustomDataFromServerInBackground({
    required dynamic cycleId,
    int? itemId,
    String? label,
  }) {
    // تنفيذ الحذف من API في الخلفية
    Future<void>(() async {
      try {
        final isLoggedIn =
            myServices.getStorage.read<bool>('is_logged_in') ?? false;
        if (!isLoggedIn) return;

        final user = _auth.currentUser;
        if (user == null) return;

        final token = await user.getIdToken();
        if (token == null || token.isEmpty) return;

        await _cycleData.deleteCycleItem(
          token: token,
          cycleId:
              cycleId is int ? cycleId : int.tryParse(cycleId.toString()) ?? 0,
          type: 'data',
          deleteType: itemId != null ? 'single' : 'by_label',
          itemId: itemId,
          label: label,
        );

        // بعد نجاح الحذف، إعادة تحميل البيانات من API
        final cycleCtrl = Get.find<CycleController>();
        final cycleIdInt =
            cycleId is int ? cycleId : int.tryParse(cycleId.toString());
        if (cycleIdInt != null && cycleIdInt > 0) {
          await cycleCtrl.fetchCycleDetails(cycleIdInt);
          // إعادة تحميل البيانات المخصصة من currentCycle
          final customDataEntries =
              cycleCtrl.currentCycle['customDataEntries'] as List<dynamic>?;
          if (customDataEntries != null && customDataEntries.isNotEmpty) {
            loadCustomDataFromApi(customDataEntries);
          } else {
            _reloadCustomDataForCurrentCycle();
          }
        }
      } catch (e) {
        // في حالة الفشل، لا شيء
      }
    });
  }
}
