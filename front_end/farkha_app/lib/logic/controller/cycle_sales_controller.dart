import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constant/strings/app_strings.dart';
import '../../core/class/status_request.dart';
import '../../core/services/initialization.dart';
import '../../data/data_source/remote/cycle_data/cycle_data.dart';
import 'cycle_controller.dart';

class SalesItem {
  final String id;
  final int birdsCount;
  final double totalWeight;
  final double pricePerKilo;
  final double totalPrice;
  final DateTime saleDate;

  SalesItem({
    required this.id,
    required this.birdsCount,
    required this.totalWeight,
    required this.pricePerKilo,
    required this.totalPrice,
    required this.saleDate,
  });

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      id: (json['id'] ?? '').toString(),
      birdsCount: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      totalWeight: double.tryParse(json['total_weight']?.toString() ?? '0.0') ?? 0.0,
      pricePerKilo: double.tryParse(json['price_per_kg']?.toString() ?? '0.0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0.0') ?? 0.0,
      saleDate: DateTime.tryParse(json['sale_date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': birdsCount,
      'total_weight': totalWeight,
      'price_per_kg': pricePerKilo,
      'total_price': totalPrice,
      'sale_date': saleDate.toIso8601String(),
    };
  }
}

class CycleSalesController extends GetxController {
  CycleSalesController({
    CycleData? cycleData,
    CycleController? cycleController,
    FirebaseAuth? auth,
    MyServices? myServices,
  })  : _cycleDataOverride = cycleData,
        _cycleControllerOverride = cycleController,
        _authOverride = auth,
        _myServicesOverride = myServices;

  final CycleData? _cycleDataOverride;
  final CycleController? _cycleControllerOverride;
  final FirebaseAuth? _authOverride;
  final MyServices? _myServicesOverride;

  final RxList<SalesItem> sales = <SalesItem>[].obs;
  final RxDouble totalSales = 0.0.obs;
  final Rx<StatusRequest> statusRequest = StatusRequest.none.obs;
  
  late final CycleData _cycleData;
  late final CycleController _cycleController;
  late final FirebaseAuth _auth;
  late final MyServices myServices;

  @override
  void onInit() {
    _cycleData = _cycleDataOverride ?? CycleData();
    _cycleController = _cycleControllerOverride ?? Get.find<CycleController>();
    _auth = _authOverride ?? FirebaseAuth.instance;
    myServices = _myServicesOverride ?? Get.find<MyServices>();
    super.onInit();
    fetchSales();
  }

  Future<void> fetchSales() async {
    final currentCycle = _cycleController.currentCycle;
    final String? cycleId = (currentCycle['id'] ?? currentCycle['cycle_id'])?.toString();
    
    if (cycleId == null) return;

    statusRequest.value = StatusRequest.loading;
    update();

    final int cycleIdInt = int.tryParse(cycleId) ?? 0;
    if (cycleIdInt > 0) {
      await _cycleController.fetchCycleDetails(cycleIdInt);
    }

    final salesVal = currentCycle['total_sales'] ?? '0.0';
    totalSales.value = double.tryParse(salesVal.toString()) ?? 0.0;
    
    if (currentCycle['sales'] != null && currentCycle['sales'] is List) {
      sales.value = (currentCycle['sales'] as List)
          .map((s) => SalesItem.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList();
    } else {
      sales.clear();
    }
    
    statusRequest.value = StatusRequest.success;
    update();
  }

  Future<void> addSale({
    required int birdsCount,
    required double totalWeight,
    required double pricePerKilo,
  }) async {
    final currentCycle = _cycleController.currentCycle;
    final cycleIdRaw = currentCycle['id'] ?? currentCycle['cycle_id'];
    final int? cycleId = int.tryParse(cycleIdRaw?.toString() ?? '');
    
    if (cycleId == null) {
      _showSnackbar(AppStrings.error, 'لم يتم العثور على معرف الدورة');
      return;
    }

    statusRequest.value = StatusRequest.loading;
    update();

    final totalPrice = totalWeight * pricePerKilo;
    
    final user = _auth.currentUser;
    if (user == null) {
      statusRequest.value = StatusRequest.failure;
      _showSnackbar(AppStrings.error, 'يجب تسجيل الدخول أولاً');
      update();
      return;
    }

    final token = await user.getIdToken();
    if (token == null) {
      statusRequest.value = StatusRequest.failure;
      _showSnackbar(AppStrings.error, 'فشل الحصول على رمز الدخول');
      update();
      return;
    }

    final Either<StatusRequest, Map<String, dynamic>> response = await _cycleData.addCycleSale(
      token: token,
      cycleId: cycleId,
      quantity: birdsCount,
      totalWeight: totalWeight,
      pricePerKg: pricePerKilo,
      totalPrice: totalPrice,
    );

    response.fold(
      (l) {
        statusRequest.value = l;
        _showSnackbar(AppStrings.error, 'فشل تسجيل عملية البيع: ${l.toString()}');
      },
      (r) {
        if (r['status'] == 'success') {
          // تحديث محلي سريع
          totalSales.value += totalPrice;
          
          // تحديث البيانات في CycleController أيضاً لضمان مزامنة الواجهة بالكامل
          _cycleController.currentCycle['total_sales'] = totalSales.value;

          // إضافة السجل للقائمة
          final saleRecord = {
            'id': r['data']?['sale_id'] ?? DateTime.now().millisecondsSinceEpoch,
            'cycle_id': cycleId,
            'quantity': birdsCount,
            'total_weight': totalWeight,
            'price_per_kg': pricePerKilo,
            'total_price': totalPrice,
            'sale_date': DateTime.now().toString().split(' ')[0], 
          };

          if (_cycleController.currentCycle['sales'] is List) {
            final List<dynamic> currentSales = List<dynamic>.from(_cycleController.currentCycle['sales'] as Iterable);
            currentSales.insert(0, saleRecord);
            _cycleController.currentCycle['sales'] = currentSales;
          } else {
            _cycleController.currentCycle['sales'] = [saleRecord];
          }

          // إعادة تحديث القائمة في الكنترولر المحلي
          fetchSales();

          _cycleController.currentCycle.refresh();

          Get.back<void>(); // إغلاق الدايالوج قبل عرض الـ Snackbar
          _showSnackbar('نجاح', 'تم تسجيل عملية البيع بنجاح', isSuccess: true);
          
          statusRequest.value = StatusRequest.success;
        } else {
          statusRequest.value = StatusRequest.failure;
          Get.back<void>(); // إغلاق الدايالوج قبل عرض الـ Snackbar
          _showSnackbar(AppStrings.error, r['message']?.toString() ?? 'فشل تسجيل عملية البيع');
        }
      }
    );
    update();
  }

  Future<void> deleteSale(String saleId) async {
    final currentCycle = _cycleController.currentCycle;
    final int? cycleId = int.tryParse(currentCycle['cycle_id']?.toString() ?? currentCycle['id']?.toString() ?? '');
    
    if (cycleId == null) {
      _showSnackbar(AppStrings.error, 'بيانات الدورة غير مكتملة');
      return;
    }

    final token = await _auth.currentUser?.getIdToken();
    if (token == null) {
      _showSnackbar(AppStrings.error, 'الرجاء تسجيل الدخول أولاً');
      return;
    }

    statusRequest.value = StatusRequest.loading;
    update();

    final response = await _cycleData.deleteCycleItem(
      token: token,
      cycleId: cycleId,
      type: 'sale',
      deleteType: 'single',
      itemId: int.tryParse(saleId),
    );

    response.fold(
      (l) {
        statusRequest.value = l;
        _showSnackbar(AppStrings.error, 'فشل حذف البيع: ${l.toString()}');
      },
      (r) {
        if (r['status'] == 'success') {
          // Find the sale to deduct the amount
          final saleToDelete = sales.firstWhereOrNull((s) => s.id == saleId);
          if (saleToDelete != null) {
            totalSales.value -= saleToDelete.totalPrice;
            _cycleController.currentCycle['total_sales'] = totalSales.value;
            sales.remove(saleToDelete);
            
            // Remove from cached list
            if (_cycleController.currentCycle['sales'] is List) {
              final List<dynamic> currentSales = List<dynamic>.from(_cycleController.currentCycle['sales'] as Iterable);
              currentSales.removeWhere((item) => item['id']?.toString() == saleId);
              _cycleController.currentCycle['sales'] = currentSales;
            }
          }
          
          statusRequest.value = StatusRequest.success;
          _showSnackbar('نجاح', 'تم الحذف بنجاح', isSuccess: true);
        } else {
          statusRequest.value = StatusRequest.failure;
          _showSnackbar(AppStrings.error, r['message']?.toString() ?? 'فشل مجهول');
        }
      },
    );
    update();
  }

  double calculateNetProfit(double totalExpenses) {
    return totalSales.value - totalExpenses;
  }

  /// عرض رسالة تنبيه بشكل آمن لتجنب No Overlay error
  void _showSnackbar(String title, String message, {bool isSuccess = false}) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(message, style: const TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: isSuccess ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(15),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      Get.snackbar(title, message, snackPosition: SnackPosition.TOP);
    }
  }
}
