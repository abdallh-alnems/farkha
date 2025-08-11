import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/functions/handing_data_controller.dart';
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

  late StatusRequest statusRequest;
  FarkhAbidData farkhAbidData = FarkhAbidData(Get.find());

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

  Future<void> getDataFarkhAbid() async {
    statusRequest = StatusRequest.loading;
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
    update();
  }

  @override
  void onInit() {
    getDataFarkhAbid();
    super.onInit();
  }
}
