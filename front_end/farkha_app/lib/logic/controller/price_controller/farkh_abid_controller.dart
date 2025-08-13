import 'dart:async';

import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/id/link_api.dart';
import '../../../core/functions/handing_data_controller.dart';
import '../../../core/services/sse_service.dart';
import '../../../data/data_source/remote/prices_data/farkh_abid_data.dart';

class FarkhAbidController extends GetxController {
  // أسعار اليوم الحالي
  String farkhAbidHigherToday = '';
  String farkhAbidLowerToday = '';
  String frakhAbdiHayaHigherToday = '';
  String frakhAbdiHayaLowerToday = '';

  // أسعار أمس (للحفاظ على التوافق)
  String farkhAbidHigherYesterday = '';
  String farkhAbidLowerYesterday = '';
  String frakhAbdiHayaHigherYesterday = '';
  String frakhAbdiHayaLowerYesterday = '';

  // تهيئة statusRequest بقيمة افتراضية
  StatusRequest statusRequest = StatusRequest.loading;
  FarkhAbidData farkhAbidData = FarkhAbidData(Get.find());

  // إضافة خدمة SSE
  late SseService _sseService;
  StreamSubscription<Map<String, dynamic>>? _sseSubscription;
  Timer? _retryTimer;

  // حساب متوسط سعر أمس للحم الأبيض
  double get farkhAbidYesterdayAverage {
    double higher = double.tryParse(farkhAbidHigherYesterday) ?? 0;
    double lower = double.tryParse(farkhAbidLowerYesterday) ?? 0;
    return (higher + lower) / 2;
  }

  // حساب متوسط سعر اليوم للحم الأبيض
  double get farkhAbidTodayAverage {
    double higher = double.tryParse(farkhAbidHigherToday) ?? 0;
    double lower = double.tryParse(farkhAbidLowerToday) ?? 0;
    return (higher + lower) / 2;
  }

  // حساب الفرق للحم الأبيض
  double get farkhAbidPriceDifference {
    return farkhAbidTodayAverage - farkhAbidYesterdayAverage;
  }

  // حساب متوسط سعر أمس للفراخ الحية
  double get frakhAbdiHayaYesterdayAverage {
    double higher = double.tryParse(frakhAbdiHayaHigherYesterday) ?? 0;
    double lower = double.tryParse(frakhAbdiHayaLowerYesterday) ?? 0;
    return (higher + lower) / 2;
  }

  // حساب متوسط سعر اليوم للفراخ الحية
  double get frakhAbdiHayaTodayAverage {
    double higher = double.tryParse(frakhAbdiHayaHigherToday) ?? 0;
    double lower = double.tryParse(frakhAbdiHayaLowerToday) ?? 0;
    return (higher + lower) / 2;
  }

  // حساب الفرق للفراخ الحية
  double get frakhAbdiHayaPriceDifference {
    return frakhAbdiHayaTodayAverage - frakhAbdiHayaYesterdayAverage;
  }

  /// بدء الاتصال بـ SSE
  Future<void> startSseConnection() async {
    try {
      // البحث عن SseService
      try {
        _sseService = Get.find<SseService>();
      } catch (e) {
        throw Exception('SseService not available');
      }

      // إنشاء الـ subscription أولاً قبل الاتصال
      _sseSubscription = _sseService.dataStream.listen(
        (data) {
          _handleSseData(data);
        },
        onError: (error) {
          print('SSE Error: $error');
          _scheduleRetry();
        },
        onDone: () {
          print('SSE connection closed');
          _scheduleRetry();
        },
        cancelOnError: false,
      );

      // الآن قم بالاتصال
      await _sseService.connect(ApiLinks.farkhAbid);
    } catch (e) {
      print('SSE connection failed: $e');
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 30), () {
      print('Retrying SSE connection...');
      startSseConnection();
    });
  }

  /// معالجة البيانات الواردة من SSE
  void _handleSseData(Map<String, dynamic> data) {
    try {
      if (data['status'] == "success" && data['data'] != null) {
        List responseData = data['data'];

        if (responseData.isNotEmpty) {
          final item = responseData[0];
          
          // التحقق من صحة البيانات قبل التحديث
          if (item['farkh_abid_higher_today'] != null && 
              item['farkh_abid_lower_today'] != null) {
            
            // تحديث أسعار اليوم الحالي
            farkhAbidHigherToday = item['farkh_abid_higher_today'].toString();
            farkhAbidLowerToday = item['farkh_abid_lower_today'].toString();
            frakhAbdiHayaHigherToday = item['frakh_abdi_haya_higher_today'].toString();
            frakhAbdiHayaLowerToday = item['frakh_abdi_haya_lower_today'].toString();

            // تحديث أسعار أمس
            farkhAbidHigherYesterday = item['farkh_abid_higher_yesterday'].toString();
            farkhAbidLowerYesterday = item['farkh_abid_lower_yesterday'].toString();
            frakhAbdiHayaHigherYesterday = item['frakh_abdi_haya_higher_yesterday'].toString();
            frakhAbdiHayaLowerYesterday = item['frakh_abdi_haya_lower_yesterday'].toString();

            statusRequest = StatusRequest.success;
            update();
          } else {
            // إذا كانت البيانات غير صحيحة، احتفظ بالبيانات السابقة
            print('Invalid data received from SSE');
          }
        } else {
          // إذا كانت البيانات فارغة، احتفظ بالبيانات السابقة
          print('Empty data received from SSE');
        }
      } else {
        // إذا كان هناك خطأ في الاستجابة، احتفظ بالبيانات السابقة
        print('Error response from SSE: ${data['status']}');
      }
    } catch (e) {
      // في حالة الخطأ، احتفظ بالبيانات السابقة
      print('Exception in _handleSseData: $e');
    }
  }

  Future<void> getDataFarkhAbid() async {
    try {
      statusRequest = StatusRequest.loading;
      update();

      var response = await farkhAbidData.getData();
      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        final mapResponse = response as Map<String, dynamic>;
        if (mapResponse['status'] == "success") {
          List data = mapResponse['data'];
          if (data.isNotEmpty) {
            final item = data[0];

            // أسعار اليوم الحالي
            farkhAbidHigherToday = item['farkh_abid_higher_today'].toString();
            farkhAbidLowerToday = item['farkh_abid_lower_today'].toString();
            frakhAbdiHayaHigherToday =
                item['frakh_abdi_haya_higher_today'].toString();
            frakhAbdiHayaLowerToday =
                item['frakh_abdi_haya_lower_today'].toString();

            // أسعار أمس
            farkhAbidHigherYesterday =
                item['farkh_abid_higher_yesterday'].toString();
            farkhAbidLowerYesterday =
                item['farkh_abid_lower_yesterday'].toString();
            frakhAbdiHayaHigherYesterday =
                item['frakh_abdi_haya_higher_yesterday'].toString();
            frakhAbdiHayaLowerYesterday =
                item['frakh_abdi_haya_lower_yesterday'].toString();
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

  @override
  void onInit() {
    try {
      // بدء الاتصال بـ SSE بدلاً من الطريقة التقليدية
      startSseConnection();
    } catch (e) {
      // إذا فشل SSE، استخدم الطريقة التقليدية
      getDataFarkhAbid();
    }
    super.onInit();
  }

  @override
  void onClose() {
    _retryTimer?.cancel();
    _sseSubscription?.cancel();
    super.onClose();
  }
}
