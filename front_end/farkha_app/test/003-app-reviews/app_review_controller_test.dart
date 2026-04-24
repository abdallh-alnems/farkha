import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/data/data_source/remote/app_review_data.dart';
import 'package:farkha_app/logic/controller/app_review_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_harness.dart';

class MockAppReviewData extends Mock implements AppReviewData {}

void main() {
  late MockAppReviewData mockReviewData;
  late AppReviewController controller;

  setUp(() {
    TestHarness.setUpGetx();
    mockReviewData = MockAppReviewData();
    controller = AppReviewController(mockReviewData);
    Get.put<AppReviewController>(controller);
  });

  tearDown(TestHarness.tearDownGetx);

  group('initial state', () {
    test('rating يبدأ بـ 0', () {
      expect(controller.rating, equals(0));
    });

    test('isSubmitting يبدأ بـ false', () {
      expect(controller.isSubmitting, isFalse);
    });
  });

  group('setRating', () {
    test('يضبط قيمة rating', () {
      controller.setRating(4);
      expect(controller.rating, equals(4));
    });
  });

  group('submit - validation', () {
    test('يمنع الإرسال إذا rating == 0', () async {
      controller.setRating(0);
      await controller.submit();
      verifyNever(() => mockReviewData.submit(
            rating: any(named: 'rating'),
          ));
      expect(controller.validationError, equals('اختار نجوم أو اكتب مشكلة أو اقتراح'));
    });
  });

  group('submit - success', () {
    test('يُرسل التقييم بنجاح', () async {
      controller.setRating(4);

      when(() => mockReviewData.submit(
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => const Right({
            'status': 'success',
            'data': {
              'review_id': 1,
              'message': 'App review saved successfully'
            }
          }));

      await controller.submit();

      expect(controller.isSubmitting, isFalse);
    });
  });

  group('submit - failure', () {
    test('يُعالج serverFailure', () async {
      controller.setRating(3);

      when(() => mockReviewData.submit(
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => const Left(StatusRequest.serverFailure));

      await controller.submit();

      expect(controller.isSubmitting, isFalse);
    });

    test('يُعالج offlineFailure ويحتفظ بالحقول', () async {
      controller.setRating(4);
      controller.issueController.text = 'مشكلة';
      controller.suggestionController.text = 'اقتراح';

      when(() => mockReviewData.submit(
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => const Left(StatusRequest.offlineFailure));

      await controller.submit();

      expect(controller.rating, equals(4));
      expect(controller.issueController.text, equals('مشكلة'));
      expect(controller.suggestionController.text, equals('اقتراح'));
      expect(controller.isSubmitting, isFalse);
    });
  });
}
