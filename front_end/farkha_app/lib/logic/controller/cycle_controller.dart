import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constant/routes/route.dart';
import '../../core/services/initialization.dart';

class CycleController extends GetxController {
  final MyServices myServices = Get.find<MyServices>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController spaceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dateRawController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static const String _storageKey = 'cycles';

  // Data
  final RxList<Map<String, dynamic>> cycles = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> currentCycle = <String, dynamic>{}.obs;

  // Edit state
  final RxBool isEdit = false.obs;
  final RxInt editIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    final stored = myServices.getStorage.read<List>(_storageKey);
    if (stored != null && stored.isNotEmpty) {
      cycles.assignAll(stored.cast<Map<String, dynamic>>());
      currentCycle.assignAll(cycles.first);
    }
  }
  

  void prepareForEdit(Map<String, dynamic> data, int index) {
    isEdit.value = true;
    editIndex.value = index;
    nameController.text = data['name'] ?? '';
    countController.text = data['chickCount'] ?? '';
    spaceController.text = data['space'] ?? '';
    dateController.text = data['startDate'] ?? '';
    dateRawController.text = data['startDateRaw'] ?? '';
  }

  String ageOf(String isoDate) {
    if (isoDate.isEmpty) return '';
    final start = DateTime.parse(isoDate);
    final now = DateTime.now();
    if (now.isBefore(start)) return 'لم تبدأ';
    final days = now.difference(start).inDays + 1;
    return '$days';
  }



  Future<void> onNext() async {
    if (!formKey.currentState!.validate()) return;

    final entry = {
      'name': nameController.text.trim(),
      'chickCount': countController.text.trim(),
      'space': spaceController.text.trim(),
      'startDate': dateController.text.trim(),
      'startDateRaw': dateRawController.text.trim(),
      // 'lastStageShown' removed
    };

    if (isEdit.value && editIndex.value >= 0) {
      cycles[editIndex.value] = entry;
      currentCycle.assignAll(entry);
      isEdit.value = false;
      editIndex.value = -1;
    } else {
      cycles.add(entry);
    }

    await myServices.getStorage.write(_storageKey, cycles.toList());
    clearFields();

    final newIndex = cycles.length - 1;
    final shouldShowTutorial = cycles.length == 2;

    Get.offNamedUntil(
      AppRoute.cycle,
      ModalRoute.withName('/'),
      arguments: {'index': newIndex, 'showTutorial': shouldShowTutorial},
    );

    // عرض الرسالة محذوف
  }

  void clearFields() {
    nameController.clear();
    countController.clear();
    spaceController.clear();
    dateController.clear();
    dateRawController.clear();
    formKey.currentState?.reset();
  }

  Future<bool> deleteCurrentCycle() async {
    final idx = cycles.indexWhere((c) => c['name'] == currentCycle['name']);
    if (idx != -1) {
      cycles.removeAt(idx);
      await myServices.getStorage.write(_storageKey, cycles.toList());
      if (cycles.isNotEmpty) {
        currentCycle.assignAll(cycles.last);
      } else {
        currentCycle.clear();
      }
      return cycles.isEmpty;
    }
    return false;
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      dateRawController.text = DateFormat('yyyy-MM-dd').format(picked);
      final formatted = DateFormat('MM-dd', 'en').format(picked);
      final dayName = DateFormat('EEEE', 'ar').format(picked);
      dateController.text = '$formatted ($dayName)';
    }
  }
}
