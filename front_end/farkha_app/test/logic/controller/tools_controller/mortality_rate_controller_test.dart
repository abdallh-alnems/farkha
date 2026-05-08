import 'package:farkha_app/logic/controller/tools_controller/mortality_rate_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/test_harness.dart';

void main() {
  setUp(TestHarness.setUpGetx);
  tearDown(TestHarness.tearDownGetx);

  group('MortalityRateController', () {
    late MortalityRateController controller;

    setUp(() {
      controller = MortalityRateController();
      Get.put<MortalityRateController>(controller);
    });

    test('القيم الابتدائية تساوي صفر', () {
      expect(controller.initialCount.value, 0);
      expect(controller.deaths.value, 0);
      expect(controller.mortalityRate.value, 0.0);
    });

    test('calculateMortalityRate يحسب النسبة بشكل صحيح', () {
      controller.initialCount.value = 1000;
      controller.deaths.value = 50;

      controller.calculateMortalityRate();

      expect(controller.mortalityRate.value, closeTo(5.0, 0.01));
    });

    test('calculateMortalityRate نسبة 0%', () {
      controller.initialCount.value = 1000;
      controller.deaths.value = 0;

      controller.calculateMortalityRate();

      expect(controller.mortalityRate.value, 0.0);
    });

    test('calculateMortalityRate نسبة 100%', () {
      controller.initialCount.value = 500;
      controller.deaths.value = 500;

      controller.calculateMortalityRate();

      expect(controller.mortalityRate.value, 100.0);
    });

    test('calculateMortalityRate يعيد صفر عند initialCount = 0', () {
      controller.initialCount.value = 0;
      controller.deaths.value = 10;

      controller.calculateMortalityRate();

      expect(controller.mortalityRate.value, 0.0);
    });

    test('reset يعيد كل القيم إلى الصفر', () {
      controller.initialCount.value = 1000;
      controller.deaths.value = 50;
      controller.mortalityRate.value = 5.0;

      controller.reset();

      expect(controller.initialCount.value, 0);
      expect(controller.deaths.value, 0);
      expect(controller.mortalityRate.value, 0.0);
    });
  });
}
