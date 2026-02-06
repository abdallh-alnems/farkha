import 'package:get/get.dart';

import '../../../data/data_source/static/chicken_data.dart';

class DarknessLevelsController extends GetxController {
  final Rx<int?> selectedDay = Rx<int?>(null);
  final RxString result = ''.obs;


  int get maxDay => darknessLevels.length;
  int? get darkness {
    if (selectedDay.value == null || selectedDay.value! <= 0) {
      return null;
    }
    return darknessLevels[selectedDay.value! - 1];
  }

  int? get light {
    final int? darknessHours = darkness;
    if (darknessHours == null) {
      return null;
    }
    return 24 - darknessHours;
  }

  String get darknessHoursFormatted {
    final int? darknessHours = darkness;
    if (darknessHours == null) {
      return '0';
    }
    return '$darknessHours';
  }

  String get lightHoursFormatted {
    final int? lightHours = light;
    if (lightHours == null) {
      return '0';
    }
    return '$lightHours';
  }

  void setDay(int day) => selectedDay.value = day;

  void calculateDarknessLevels() {
    if (selectedDay.value == null) {
      result.value = 'الرجاء اختيار اليوم';
      return;
    }

    final int? darknessHours = darkness;
    if (darknessHours == null) {
      result.value = 'لا يوجد إظلام في اليوم ${selectedDay.value}';
      return;
    }

    if (darknessHours == 0) {
      result.value = 'لا يوجد إظلام في اليوم ${selectedDay.value}';
    } else {
      result.value =
          'ساعات الإظلام في اليوم ${selectedDay.value}: $darknessHours ساعة';
    }
  }
}
