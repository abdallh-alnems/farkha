import 'package:farkha_app/logic/controller/tools_controller/darkness_levels_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/test_harness.dart';

void main() {
  setUp(TestHarness.setUpGetx);
  tearDown(TestHarness.tearDownGetx);

  group('DarknessLevelsController', () {
    late DarknessLevelsController controller;

    setUp(() {
      controller = DarknessLevelsController();
      Get.put<DarknessLevelsController>(controller);
    });

    test('القيم الابتدائية فارغة', () {
      expect(controller.selectedDay.value, isNull);
      expect(controller.result.value, '');
      expect(controller.darkness, isNull);
      expect(controller.light, isNull);
    });

    test('setDay يحدد اليوم المختار', () {
      controller.setDay(5);

      expect(controller.selectedDay.value, 5);
    });

    test('darkness يُرجع قيمة صحيحة لليوم 5', () {
      controller.setDay(5);

      expect(controller.darkness, 1);
    });

    test('darkness يُرجع 0 لليوم 1', () {
      controller.setDay(1);

      expect(controller.darkness, 0);
    });

    test('light = 24 - darkness', () {
      controller.setDay(5);

      expect(controller.light, 23);
    });

    test('darknessHoursFormatted و lightHoursFormatted يعملان', () {
      controller.setDay(12);

      expect(controller.darknessHoursFormatted, '6');
      expect(controller.lightHoursFormatted, '18');
    });

    test('darknessHoursFormatted = 0 عند عدم الاختيار', () {
      expect(controller.darknessHoursFormatted, '0');
      expect(controller.lightHoursFormatted, '0');
    });

    test('calculateDarknessLevels يُظهر رسالة عدم وجود إظلام', () {
      controller.setDay(1);

      controller.calculateDarknessLevels();

      expect(controller.result.value, contains('لا يوجد إظلام'));
    });

    test('calculateDarknessLevels يُظهر ساعات الإظلام', () {
      controller.setDay(12);

      controller.calculateDarknessLevels();

      expect(controller.result.value, contains('6'));
      expect(controller.result.value, contains('ساعة'));
    });

    test('calculateDarknessLevels يطلب الاختيار عند عدم التحديد', () {
      controller.calculateDarknessLevels();

      expect(controller.result.value, 'الرجاء اختيار اليوم');
    });

    test('maxDay يُرجع طول القائمة', () {
      expect(controller.maxDay, greaterThan(0));
    });
  });
}
