import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/data/data_source/remote/cycle_feedback_data.dart';
import 'package:farkha_app/logic/controller/cycle_feedback_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_harness.dart';

class MockCycleFeedbackData extends Mock implements CycleFeedbackData {}

void main() {
  late MockCycleFeedbackData mockData;
  late GetStorage storage;
  late CycleFeedbackController controller;

  setUp(() async {
    TestHarness.setUpGetx();
    await TestHarness.ensureGetStorage();
    storage = await TestHarness.getStorage();
    await storage.erase();

    mockData = MockCycleFeedbackData();
    controller = CycleFeedbackController(mockData);
    Get.put<CycleFeedbackController>(controller);
  });

  tearDown(() {
    TestHarness.tearDownGetx();
  });

  void setFirstCycleOpen(int daysAgo) {
    storage.write(
      'cycle_fb_first_cycle_open',
      DateTime.now().subtract(Duration(days: daysAgo)).toIso8601String(),
    );
  }

  void setOpenCount(int count) {
    storage.write('cycle_fb_opens_since_last', count);
  }

  void setLastShown(int daysAgo) {
    storage.write(
      'cycle_fb_last_shown',
      DateTime.now().subtract(Duration(days: daysAgo)).toIso8601String(),
    );
  }

  group('recordCycleOpen', () {
    test('sets first_cycle_open on first call', () {
      expect(storage.read<String>('cycle_fb_first_cycle_open'), isNull);

      controller.recordCycleOpen();

      expect(storage.read<String>('cycle_fb_first_cycle_open'), isNotNull);
    });

    test('does not overwrite first_cycle_open on subsequent calls', () {
      controller.recordCycleOpen();
      final first = storage.read<String>('cycle_fb_first_cycle_open');

      controller.recordCycleOpen();
      final second = storage.read<String>('cycle_fb_first_cycle_open');

      expect(first, equals(second));
    });

    test('increments opens counter', () {
      controller.recordCycleOpen();
      expect(storage.read<int>('cycle_fb_opens_since_last'), equals(1));

      controller.recordCycleOpen();
      expect(storage.read<int>('cycle_fb_opens_since_last'), equals(2));
    });
  });

  group('maybeShowDialog timing', () {
    test('does not show before 25 opens', () async {
      setFirstCycleOpen(30);
      setOpenCount(15);

      await controller.maybeShowDialog();

      expect(storage.read<String>('cycle_fb_last_shown'), isNull);
    });

    test('does not show before 25 days even with 25 opens', () async {
      setFirstCycleOpen(20);
      setOpenCount(25);

      await controller.maybeShowDialog();

      expect(storage.read<String>('cycle_fb_last_shown'), isNull);
    });

    test('shows after 25 days + 25 opens', () async {
      setFirstCycleOpen(26);
      setOpenCount(25);

      await controller.maybeShowDialog();

      expect(storage.read<String>('cycle_fb_last_shown'), isNotNull);
    });

    test('resets opens counter after showing', () async {
      setFirstCycleOpen(26);
      setOpenCount(25);

      await controller.maybeShowDialog();

      expect(storage.read<int>('cycle_fb_opens_since_last'), equals(0));
    });

    test('does not show again before 60 days since last shown', () async {
      setFirstCycleOpen(100);
      setLastShown(30);
      setOpenCount(25);

      await controller.maybeShowDialog();

      expect(storage.read<int>('cycle_fb_opens_since_last'), equals(25));
    });

    test('shows again after 60 days + 10 opens since last shown', () async {
      setFirstCycleOpen(200);
      setLastShown(61);
      setOpenCount(25);

      await controller.maybeShowDialog();

      expect(storage.read<int>('cycle_fb_opens_since_last'), equals(0));
    });

    test('does not show after 60 days but less than 25 opens', () async {
      setFirstCycleOpen(200);
      setLastShown(61);
      setOpenCount(15);

      await controller.maybeShowDialog();

      expect(storage.read<int>('cycle_fb_opens_since_last'), equals(15));
    });
  });

  group('submit', () {
    test('rating = 0 → Arabic validation error, no network call', () async {
      controller.rating = 0;

      await controller.submit();

      verifyNever(
        () => mockData.submit(
          rating: any(named: 'rating'),
          issue: any(named: 'issue'),
          suggestion: any(named: 'suggestion'),
          appVersion: any(named: 'appVersion'),
          platform: any(named: 'platform'),
        ),
      );
      expect(controller.validationError, equals('اختَر عدد النجوم'));
    });

    test('success → statusRequest = success', () async {
      controller.rating = 4;

      when(() => mockData.submit(
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => const Right({
            'status': 'success',
            'data': {
              'feedback_id': 1,
              'message': 'Feedback saved successfully'
            }
          }));

      await controller.submit();

      expect(controller.statusRequest, equals(StatusRequest.success));
    });

    test('network failure → offlineFailure, inputs preserved', () async {
      controller.rating = 4;
      controller.issueController.text = 'مشكلة';
      controller.suggestionController.text = 'اقتراح';

      when(() => mockData.submit(
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => const Left(StatusRequest.offlineFailure));

      await controller.submit();

      expect(controller.statusRequest, equals(StatusRequest.offlineFailure));
      expect(controller.rating, equals(4));
      expect(controller.issueController.text, equals('مشكلة'));
      expect(controller.suggestionController.text, equals('اقتراح'));
    });

    test('server failure → serverFailure', () async {
      controller.rating = 3;

      when(() => mockData.submit(
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => const Left(StatusRequest.serverFailure));

      await controller.submit();

      expect(controller.statusRequest, equals(StatusRequest.serverFailure));
      expect(controller.rating, equals(3));
    });

    test('retry after failure succeeds → success', () async {
      controller.rating = 4;

      when(() => mockData.submit(
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => const Left(StatusRequest.offlineFailure));

      await controller.submit();
      expect(controller.statusRequest, equals(StatusRequest.offlineFailure));

      when(() => mockData.submit(
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => const Right({
            'status': 'success',
            'data': {'feedback_id': 2, 'message': 'Feedback saved successfully'}
          }));

      await controller.submit();
      expect(controller.statusRequest, equals(StatusRequest.success));
    });
  });

  group('skip', () {
    test('skip does not call network', () {
      controller.skip();

      verifyNever(
        () => mockData.submit(
          rating: any(named: 'rating'),
          issue: any(named: 'issue'),
          suggestion: any(named: 'suggestion'),
          appVersion: any(named: 'appVersion'),
          platform: any(named: 'platform'),
        ),
      );
    });
  });

  group('setRating', () {
    test('sets rating and clears validation error', () {
      controller.validationError = 'some error';
      controller.setRating(3);
      expect(controller.rating, equals(3));
      expect(controller.validationError, isNull);
    });
  });

  group('initial state', () {
    test('rating starts at 0', () {
      expect(controller.rating, equals(0));
    });

    test('statusRequest starts at none', () {
      expect(controller.statusRequest, equals(StatusRequest.none));
    });

    test('validationError starts null', () {
      expect(controller.validationError, isNull);
    });
  });
}
