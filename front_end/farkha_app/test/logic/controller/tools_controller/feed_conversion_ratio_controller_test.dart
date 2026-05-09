import 'package:farkha_app/logic/controller/tools_controller/feed_conversion_ratio_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/test_harness.dart';

void main() {
  setUp(TestHarness.setUpGetx);
  tearDown(TestHarness.tearDownGetx);

  group('FcrController', () {
    late FcrController controller;

    setUp(() {
      controller = FcrController();
      Get.put<FcrController>(controller);
    });

    tearDown(() {
      controller.onClose();
    });

    test('القيمة الابتدائية fcr = 0', () {
      expect(controller.fcr.value, 0.0);
    });

    test('calculateFCR يحسب المعامل بشكل صحيح', () {
      controller.feedConsumedController.text = '3.6';
      controller.currentWeightController.text = '1.8';

      controller.calculateFCR();

      const weightGain = 1.8 - 0.045;
      const expected = 3.6 / weightGain;
      expect(controller.fcr.value, closeTo(expected, 0.01));
    });

    test('calculateFCR يعيد صفر عند وزن أقل من الابتدائي', () {
      controller.feedConsumedController.text = '1.0';
      controller.currentWeightController.text = '0.03';

      controller.calculateFCR();

      expect(controller.fcr.value, 0.0);
    });

    test('calculateFCR يتعامل مع مدخلات فارغة', () {
      controller.feedConsumedController.text = '';
      controller.currentWeightController.text = '';

      controller.calculateFCR();

      expect(controller.fcr.value, 0.0);
    });

    test('getFcrQuality ممتاز عند <= 1.6', () {
      controller.fcr.value = 1.5;
      expect(controller.getFcrQuality(), 0);
    });

    test('getFcrQuality جيد عند <= 1.8', () {
      controller.fcr.value = 1.7;
      expect(controller.getFcrQuality(), 1);
    });

    test('getFcrQuality مقبول عند <= 1.9', () {
      controller.fcr.value = 1.9;
      expect(controller.getFcrQuality(), 2);
    });

    test('getFcrQuality ضعيف عند > 1.9', () {
      controller.fcr.value = 2.5;
      expect(controller.getFcrQuality(), 3);
    });

    test('getFcrQuality يعيد -1 عند fcr <= 0', () {
      controller.fcr.value = 0.0;
      expect(controller.getFcrQuality(), -1);
    });
  });
}
