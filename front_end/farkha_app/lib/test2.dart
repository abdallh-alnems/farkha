// import 'package:farkha_app/core/constant/routes/route.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:intl/intl.dart';

// import '../../data/data_source/static/growth_parameters.dart';

// class CycleController extends GetxController with GetTickerProviderStateMixin {
//   // متحكمات الإدخال
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController dateController = TextEditingController();
//   final TextEditingController countController = TextEditingController();
//   final TextEditingController spaceController = TextEditingController();

//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   final GetStorage storage = GetStorage();

//   // القوائم والمؤشرات
//   RxList<Map<String, dynamic>> cycles = <Map<String, dynamic>>[].obs;
//   RxInt currentIndex = 0.obs;
//   final PageController pageController = PageController();
//   RxBool showGestureTutorial = false.obs;
//   RxBool shouldJumpToLast = false.obs;

//   // سهم الإرشاد
//   late AnimationController arrowController;
//   late Animation<Offset> arrowAnimation;

//   // بيانات العمر → الرطوبة → الكثافة
//   RxInt selectedChickenAge = 0.obs;
//   RxString ageHumidityRange = ''.obs;
//   RxInt chickensPerSquareMeter = 0.obs;
//   RxInt currentTemperature = 0.obs;

//   // نصوص العرض لدرجة الحرارة والرطوبة
//   RxString temperatureText = ''.obs;
//   RxString humidityText = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadCycles();
//     if (cycles.isNotEmpty) {
//       _updateAgeDependentValues(cycles[currentIndex.value]);
//     }

//     arrowController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 800),
//     );
//     arrowAnimation = Tween<Offset>(
//       begin: Offset(-0.2, 0),
//       end: Offset(0.2, 0),
//     ).animate(
//       CurvedAnimation(parent: arrowController, curve: Curves.easeInOut),
//     );
//     arrowController.repeat(reverse: true);
//   }

//   @override
//   void onClose() {
//     nameController.dispose();
//     dateController.dispose();
//     countController.dispose();
//     spaceController.dispose();
//     pageController.dispose();
//     arrowController.dispose();
//     super.onClose();
//   }

//   // تحميل الدورات من التخزين
//   void loadCycles() {
//     var stored = storage.read('cycles');
//     if (stored != null) {
//       cycles.assignAll(List<Map<String, dynamic>>.from(stored));
//     }
//   }

//   // حساب عمر الدورة بالأيام (اليوم الأول = 1)
//   int _computeAgeDays(Map<String, dynamic> cycle) {
//     final s = cycle['startDate'] as String? ?? '';
//     if (s.isEmpty) return 0;
//     final start = DateTime.parse(s);
//     final now = DateTime.now();
//     if (now.isBefore(start)) {
//       return 0;
//     } else {
//       return now.difference(start).inDays + 1;
//     }
//   }

//   // تحديث القيم المبنية على العمر
//   void _updateAgeDependentValues(Map<String, dynamic> cycle) {
//     final days = _computeAgeDays(cycle);
//     selectedChickenAge.value = days;

//     if (days == 0) {
//       // قبل بدء الدورة
//       temperatureText.value = 'لم تبدأ';
//       humidityText.value = 'لم تبدأ';
//     } else {
//       // بعد بدء الدورة
//       // رطوبة وكثافة
//       if (days <= 7) {
//         ageHumidityRange.value = '60-70%';
//         chickensPerSquareMeter.value = 30;
//       } else if (days <= 14) {
//         ageHumidityRange.value = '60-70%';
//         chickensPerSquareMeter.value = 25;
//       } else if (days <= 21) {
//         ageHumidityRange.value = '50-60%';
//         chickensPerSquareMeter.value = 20;
//       } else if (days <= 28) {
//         ageHumidityRange.value = '50-60%';
//         chickensPerSquareMeter.value = 15;
//       } else {
//         ageHumidityRange.value = '50-55%';
//         chickensPerSquareMeter.value = 10;
//       }

//       // درجة الحرارة من القائمة
//       if (days - 1 < temperatureList.length) {
//         currentTemperature.value = temperatureList[days - 1];
//       } else {
//         currentTemperature.value = temperatureList.last;
//       }

//       // نصوص العرض
//       temperatureText.value = '${currentTemperature.value}°C';
//       humidityText.value = ageHumidityRange.value;
//     }
//   }

//   // حفظ دورة جديدة
//   void saveCycleData() {
//     final cycle = {
//       'name': nameController.text,
//       'startDate': dateController.text,
//       'cycleType': 'تسمين',
//       'chickCount': countController.text,
//       'space': spaceController.text,
//       'farmingSystem': 'أرضي',
//     };
//     cycles.add(cycle);
//     currentIndex.value = cycles.length - 1;
//     storage.write('cycles', cycles.toList());
//     _updateAgeDependentValues(cycle);
//   }

//   // تحديث دورة قائمة
//   void updateCycle(Map<String, dynamic> updated) {
//     final idx = cycles.indexWhere((c) => c['name'] == currentCycle['name']);
//     if (idx != -1) {
//       cycles[idx] = updated;
//       currentIndex.value = idx;
//       storage.write('cycles', cycles.toList());
//       _updateAgeDependentValues(updated);
//     }
//   }

//   // اختيار التاريخ
//   void pickDate(BuildContext ctx) async {
//     final picked = await showDatePicker(
//       context: ctx,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2025),
//       lastDate: DateTime(2030),
//       locale: const Locale('ar'),
//     );
//     if (picked != null) {
//       dateController.text = DateFormat('yyyy-MM-dd').format(picked);
//     }
//   }

//   // زر التالي (حفظ/تعديل)
//   void onNext({bool isEdit = false}) {
//     final stored = storage.read('cycles');
//     if (formKey.currentState!.validate()) {
//       final name = nameController.text.trim();
//       if (!isEdit) {
//         if (cycles.any((c) => c['name']?.toString().trim() == name)) {
//           Get.snackbar(
//             'خطأ',
//             'اسم الدورة موجود بالفعل',
//             backgroundColor: Colors.redAccent,
//             colorText: Colors.white,
//           );
//           return;
//         }
//       } else {
//         if (cycles.any(
//           (c) => c['name']?.toString().trim() == name && c != currentCycle,
//         )) {
//           Get.snackbar(
//             'تنبية',
//             'اسم الدورة موجود بالفعل',
//             backgroundColor: Colors.redAccent,
//             colorText: Colors.white,
//           );
//           return;
//         }
//       }

//       if (isEdit) {
//         updateCycle({
//           'name': nameController.text,
//           'startDate': dateController.text,
//           'cycleType': 'تسمين',
//           'chickCount': countController.text,
//           'space': spaceController.text,
//           'farmingSystem': 'أرضي',
//         });
//       } else {
//         saveCycleData();
//       }

//       nameController.clear();
//       dateController.clear();
//       countController.clear();
//       spaceController.clear();

//       if (cycles.length == 2) showGestureTutorial.value = true;
//       shouldJumpToLast.value = true;

//       if (stored != null && stored is List && stored.isNotEmpty) {
//         Get.back(result: cycles.last);
//       } else {
//         Get.offAndToNamed(AppRoute.cycle, result: cycles.last);
//       }
//     }
//   }

//   // إضافة دورة (بدون onNext)
//   void addCycle(Map<String, dynamic> newCycle) {
//     cycles.add(newCycle);
//     currentIndex.value = cycles.length - 1;
//     storage.write('cycles', cycles.toList());
//     _updateAgeDependentValues(newCycle);
//     if (cycles.length == 2) showGestureTutorial.value = true;
//   }

//   // عند تغيير الصفحة
//   void onPageChanged(int idx) {
//     currentIndex.value = idx;
//     _updateAgeDependentValues(cycles[idx]);
//     if (showGestureTutorial.value && idx != cycles.length - 1) {
//       showGestureTutorial.value = false;
//     }
//   }

//   // حذف الدورة الحالية
//   void deleteCurrentCycle() {
//     if (cycles.isNotEmpty) {
//       final idx = currentIndex.value;
//       cycles.removeAt(idx);
//       storage.write('cycles', cycles.toList());
//       if (cycles.isEmpty) {
//         currentIndex.value = 0;
//       } else if (idx >= cycles.length) {
//         currentIndex.value = cycles.length - 1;
//       }
//       pageController.jumpToPage(currentIndex.value);
//     }
//   }

//   // getter للدورة الحالية
//   Map<String, dynamic> get currentCycle =>
//       cycles.isNotEmpty ? cycles[currentIndex.value] : {};
// }
