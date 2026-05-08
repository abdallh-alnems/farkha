import 'package:farkha_app/logic/controller/tools_controller/adg_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/test_harness.dart';

void main() {
  setUp(TestHarness.setUpGetx);
  tearDown(TestHarness.tearDownGetx);

  group('AdgController', () {
    late AdgController controller;

    setUp(() {
      controller = AdgController();
      Get.put<AdgController>(controller);
    });

    tearDown(() {
      controller.onClose();
    });

    test('القيمة الابتدائية لـ adg تساوي صفر', () {
      expect(controller.adg.value, 0.0);
    });

    test('calculateADG يحسب النمو اليومي بشكل صحيح', () {
      controller.daysController.text = '35';
      controller.currentWeightKgController.text = '1.8';

      controller.calculateADG();

      final currentWeightG = 1.8 * 1000;
      final expected = (currentWeightG - 45) / 35;
      expect(controller.adg.value, closeTo(expected, 0.01));
    });

    test('calculateADG يعيد صفر عند وزن أقل من الابتدائي', () {
      controller.daysController.text = '10';
      controller.currentWeightKgController.text = '0.03';

      controller.calculateADG();

      expect(controller.adg.value, 0.0);
    });

    test('calculateADG يعيد صفر عند أيام صفر', () {
      controller.daysController.text = '0';
      controller.currentWeightKgController.text = '1.8';

      controller.calculateADG();

      expect(controller.adg.value, 0.0);
    });

    test('calculateADG يتعامل مع مدخلات فارغة', () {
      controller.daysController.text = '';
      controller.currentWeightKgController.text = '';

      controller.calculateADG();

      expect(controller.adg.value, 0.0);
    });

    test('getAdgQuality ممتاز عند >= 55', () {
      controller.adg.value = 60;
      expect(controller.getAdgQuality(), 0);
    });

    test('getAdgQuality جيد عند >= 45', () {
      controller.adg.value = 50;
      expect(controller.getAdgQuality(), 1);
    });

    test('getAdgQuality مقبول عند >= 35', () {
      controller.adg.value = 40;
      expect(controller.getAdgQuality(), 2);
    });

    test('getAdgQuality يحتاج تحسين عند < 35', () {
      controller.adg.value = 20;
      expect(controller.getAdgQuality(), 3);
    });

    test('reset يمسح الحقول ويعيد adg إلى صفر', () {
      controller.daysController.text = '35';
      controller.currentWeightKgController.text = '1.8';
      controller.adg.value = 50;

      controller.reset();

      expect(controller.daysController.text, '');
      expect(controller.currentWeightKgController.text, '');
      expect(controller.adg.value, 0.0);
    });
  });
}
