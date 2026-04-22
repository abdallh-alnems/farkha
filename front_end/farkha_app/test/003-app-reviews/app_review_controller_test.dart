import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/data/data_source/remote/app_review_data.dart';
import 'package:farkha_app/data/model/app_review_model.dart';
import 'package:farkha_app/logic/controller/app_review_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_harness.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockAppReviewData extends Mock implements AppReviewData {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockAppReviewData mockReviewData;
  late AppReviewController controller;

  setUp(() {
    TestHarness.setUpGetx();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockReviewData = MockAppReviewData();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.getIdToken()).thenAnswer((_) async => 'fake-token');

    when(() => mockReviewData.fetchMine(token: any(named: 'token')))
        .thenAnswer((_) async => {
              'status': 'success',
              'data': {'review': null}
            });

    controller = AppReviewController(
      mockReviewData,
      auth: mockAuth,
    );
    Get.put<AppReviewController>(controller);
  });

  tearDown(TestHarness.tearDownGetx);

  group('AppReviewController initial state', () {
    test('rating يبدأ بـ 0', () {
      expect(controller.rating, equals(0));
    });

    test('isSubmitting يبدأ بـ false', () {
      expect(controller.isSubmitting, isFalse);
    });

    test('existingReview يبدأ بـ null', () {
      expect(controller.existingReview, isNull);
    });

    test('statusRequest يتغيّر بعد fetchMyReview', () {
      expect(controller.statusRequest, isNot(equals(StatusRequest.none)));
    });
  });

  group('setRating', () {
    test('يضبط قيمة rating', () {
      controller.setRating(4);
      expect(controller.rating, equals(4));
    });
  });

  group('submit - validation', () {
    test('يمنع الإرسال إذا rating == 0 ويضبط validationError', () async {
      controller.setRating(0);
      await controller.submit();
      verifyNever(() => mockReviewData.upsert(
            token: any(named: 'token'),
            rating: any(named: 'rating'),
          ));
      expect(controller.rating, equals(0));
      expect(controller.validationError, equals('اختيار عدد النجوم مطلوب'));
    });
  });

  group('submit - success', () {
    test('يُرسل التقييم بنجاح ويعيد statusRequest = success', () async {
      controller.setRating(4);

      when(() => mockReviewData.upsert(
            token: any(named: 'token'),
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => {
            'status': 'success',
            'data': {
              'review_id': 1,
              'was_created': true,
              'message': 'App review saved successfully'
            }
          });

      await controller.submit();

      expect(controller.statusRequest, equals(StatusRequest.success));
      expect(controller.isSubmitting, isFalse);
    });
  });

  group('submit - failure', () {
    test('يُعالج StatusRequest.serverFailure', () async {
      controller.setRating(3);

      when(() => mockReviewData.upsert(
            token: any(named: 'token'),
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => StatusRequest.serverFailure);

      await controller.submit();

      expect(controller.statusRequest, equals(StatusRequest.serverFailure));
      expect(controller.isSubmitting, isFalse);
    });

    test('يُعالج StatusRequest.offlineFailure بدون إعادة تعيين الحقول (US3)', () async {
      controller.setRating(4);
      controller.issueController.text = 'مشكلة';
      controller.suggestionController.text = 'اقتراح';

      when(() => mockReviewData.upsert(
            token: any(named: 'token'),
            rating: any(named: 'rating'),
            issue: any(named: 'issue'),
            suggestion: any(named: 'suggestion'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async => StatusRequest.offlineFailure);

      await controller.submit();

      expect(controller.statusRequest, equals(StatusRequest.offlineFailure));
      expect(controller.rating, equals(4));
      expect(controller.issueController.text, equals('مشكلة'));
      expect(controller.suggestionController.text, equals('اقتراح'));
      expect(controller.isSubmitting, isFalse);
    });
  });

  group('fetchMyReview', () {
    test('يملأ الحقول إذا وُجد تقييم سابق', () async {
      when(() => mockReviewData.fetchMine(token: any(named: 'token')))
          .thenAnswer((_) async => {
                'status': 'success',
                'data': {
                  'review': {
                    'id': 7,
                    'user_id': 12,
                    'rating': 4,
                    'issue': 'مشكلة',
                    'suggestion': null,
                    'app_version': '6.1.8+37',
                    'platform': 'android',
                    'created_at': '2026-04-21 09:12:00',
                    'updated_at': '2026-04-21 09:12:00',
                  }
                }
              });

      await controller.fetchMyReview();

      expect(controller.rating, equals(4));
      expect(controller.issueController.text, equals('مشكلة'));
      expect(controller.suggestionController.text, isEmpty);
      expect(controller.existingReview, isNotNull);
      expect(controller.statusRequest, equals(StatusRequest.success));
    });

    test('يُبقي الحقول فارغة إذا لا يوجد تقييم سابق', () async {
      when(() => mockReviewData.fetchMine(token: any(named: 'token')))
          .thenAnswer((_) async => {
                'status': 'success',
                'data': {'review': null}
              });

      await controller.fetchMyReview();

      expect(controller.rating, equals(0));
      expect(controller.existingReview, isNull);
      expect(controller.statusRequest, equals(StatusRequest.success));
    });

    test('يُعالج فشل الشبكة', () async {
      when(() => mockReviewData.fetchMine(token: any(named: 'token')))
          .thenAnswer((_) async => StatusRequest.offlineFailure);

      await controller.fetchMyReview();

      expect(controller.statusRequest, equals(StatusRequest.offlineFailure));
    });
  });

  group('DI', () {
    test('يقبل auth مخصّص', () {
      final ctrl = AppReviewController(mockReviewData, auth: mockAuth);
      expect(ctrl, isNotNull);
      expect(ctrl.rating, equals(0));
    });
  });
}
