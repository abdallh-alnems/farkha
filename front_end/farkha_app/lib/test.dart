// // lib/logic/controller/cycle_controller.dart

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

//   // قائمة الدورات والفهرس الحالي
//   RxList<Map<String, dynamic>> cycles = <Map<String, dynamic>>[].obs;
//   RxInt currentIndex = 0.obs;
//   final PageController pageController = PageController();
//   RxBool showGestureTutorial = false.obs;
//   RxBool shouldJumpToLast = false.obs;

//   // سهم الإرشاد
//   late AnimationController arrowController;
//   late Animation<Offset> arrowAnimation;

//   @override
//   void onInit() {
//     super.onInit();
//     // تحميل الدورات المحفوظة
//     final stored = storage.read('cycles');
//     if (stored != null) {
//       cycles.assignAll(List<Map<String, dynamic>>.from(stored));
//     }
//     // إعداد سهم الإرشاد
//     arrowController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 800),
//     )..repeat(reverse: true);
//     arrowAnimation = Tween<Offset>(
//       begin: Offset(-0.2, 0),
//       end: Offset(0.2, 0),
//     ).animate(
//       CurvedAnimation(parent: arrowController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void onClose() {
//     // تحرير الموارد
//     nameController.dispose();
//     dateController.dispose();
//     countController.dispose();
//     spaceController.dispose();
//     pageController.dispose();
//     arrowController.dispose();
//     super.onClose();
//   }

//   /// تحويل أي قيمة إلى int بأمان
//   int _toInt(dynamic value) =>
//       value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

//   /// حساب عمر الدورة بالأيام (اليوم الأول = 1)
//   int getCycleAgeDays(Map<String, dynamic> cycle) {
//     final raw = cycle['ageDays'];
//     if (raw != null) return _toInt(raw);
//     final start = cycle['startDate'];
//     if (start is String && start.isNotEmpty) {
//       try {
//         return DateTime.now().difference(DateTime.parse(start)).inDays + 1;
//       } catch (_) {}
//     }
//     return 1;
//   }

//   /// إرجاع العمر كنص
//   String getCycleAge(Map<String, dynamic> cycle) =>
//       getCycleAgeDays(cycle).toString();

//   /// حساب الكثافة: عدد الفراخ ÷ القدرة الاستيعابية للمتر² حسب العمر
//   double getDensity(Map<String, dynamic> cycle) {
//     final age = getCycleAgeDays(cycle);
//     final capacity =
//         age < 7
//             ? 30
//             : age < 15
//             ? 20
//             : 10;
//     return _toInt(cycle['chickCount']) / capacity;
//   }

//   /// استهلاك فرخ واحد في اليوم (جرامات)
//   int _perChickFeedAtAge(int age) {
//     final idx = (age - 1).clamp(0, feedConsumptions.length - 1);
//     return feedConsumptions[idx];
//   }

//   /// العلف اليومي الإجمالي (g أو Kg)
//   String getTotalDailyFeed(Map<String, dynamic> cycle) {
//     final age = getCycleAgeDays(cycle);
//     final perChick = _perChickFeedAtAge(age);
//     final count = _toInt(cycle['chickCount']);
//     final total = perChick * count;
//     return total >= 1000
//         ? '${(total / 1000).toStringAsFixed(0)}Kg'
//         : '${total} g';
//   }

//   /// نوع العلف حسب العمر
//   String getFeedType(int age) {
//     if (age <= 14) return 'بادي';
//     if (age <= 28) return 'نامي';
//     return 'ناهي';
//   }

//   /// الرطوبة الموصى بها حسب العمر
//   String calculateHumidity(Map<String, dynamic> cycle) {
//     final days = getCycleAgeDays(cycle);
//     if (days <= 14) return '60-70%';
//     if (days <= 28) return '50-60%';
//     return '50-55%';
//   }

//   /// درجة الحرارة الموصى بها حسب العمر
//   String calculateTemperature(Map<String, dynamic> cycle) {
//     final days = getCycleAgeDays(cycle);
//     final idx = (days - 1).clamp(0, temperatureList.length - 1);
//     return '${temperatureList[idx]}°C';
//   }

//   /// اختيار تاريخ بداية الدورة
//   Future<void> pickDate(BuildContext ctx) async {
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

//   /// حفظ دورة جديدة
//   void saveCycleData() {
//     final cycle = {
//       'name': nameController.text.trim(),
//       'startDate': dateController.text,
//       'chickCount': countController.text,
//       'space': spaceController.text,
//     };
//     cycles.add(cycle);
//     currentIndex.value = cycles.length - 1;
//     storage.write('cycles', cycles.toList());
//   }

//   /// تحديث دورة قائمة
//   void updateCycle(Map<String, dynamic> updated) {
//     if (cycles.isEmpty) return;
//     cycles[currentIndex.value] = updated;
//     storage.write('cycles', cycles.toList());
//   }

//   /// زر التالي (حفظ/تعديل)
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

//   /// إضافة دورة جديدة مباشرة
//   void addCycle(Map<String, dynamic> newCycle) {
//     cycles.add(newCycle);
//     storage.write('cycles', cycles.toList());
//     if (cycles.length == 2) showGestureTutorial.value = true;
//   }

//   /// عند تغيير الصفحة
//   void onPageChanged(int idx) => currentIndex.value = idx;

//   /// حذف الدورة الحالية
//   void deleteCurrentCycle() {
//     if (cycles.isEmpty) return;
//     cycles.removeAt(currentIndex.value);
//     storage.write('cycles', cycles.toList());
//     if (currentIndex.value >= cycles.length) {
//       currentIndex.value = cycles.length - 1;
//     }
//   }

//   /// الدورة الحالية
//   Map<String, dynamic> get currentCycle =>
//       cycles.isNotEmpty ? cycles[currentIndex.value] : {};
// }
