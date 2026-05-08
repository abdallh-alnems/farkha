import 'package:farkha_app/core/class/crud.dart';
import 'package:farkha_app/logic/controller/price_controller/price_history_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/fake_crud.dart';
import '../../../helpers/test_harness.dart';

void main() {
  setUp(TestHarness.setUpGetx);
  tearDown(TestHarness.tearDownGetx);

  group('PriceHistoryController', () {
    late PriceHistoryController controller;

    setUp(() {
      Get.put<Crud>(FakeCrud());
      controller = PriceHistoryController(
        typeId: 1,
        typeName: 'دجاج تسمين',
      );
    });

    test('typeId و typeName محفوظان', () {
      expect(controller.typeId, 1);
      expect(controller.typeName, 'دجاج تسمين');
    });

    test('isFiltering = false بدون فلتر', () {
      expect(controller.isFiltering, isFalse);
    });

    test('isFiltering = true مع فلتر تاريخ', () {
      controller.setFilter(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );

      expect(controller.isFiltering, isTrue);
    });

    test('clearFilter يزيل الفلتر', () {
      controller.setFilter(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );

      controller.clearFilter();

      expect(controller.isFiltering, isFalse);
    });

    test('isSingleDayFilter = true عند تطابق تاريخ البداية والنهاية', () {
      controller.setFilter(
        start: DateTime(2026, 1, 15),
        end: DateTime(2026, 1, 15),
      );

      expect(controller.isSingleDayFilter, isTrue);
    });

    test('isSingleDayFilter = false عند اختلاف التواريخ', () {
      controller.setFilter(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );

      expect(controller.isSingleDayFilter, isFalse);
    });

    test('isLoadingMore الابتدائي = false', () {
      expect(controller.isLoadingMore, isFalse);
    });

    test('hasMore الابتدائي = true', () {
      expect(controller.hasMore, isTrue);
    });
  });
}
