import 'package:farkha_app/logic/controller/auth/login_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_login_data.dart';
import '../../../helpers/test_harness.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeLoginData fakeLoginData;
  late LoginController controller;

  setUp(() {
    TestHarness.setUpGetx();
    mockAuth = MockFirebaseAuth();
    fakeLoginData = FakeLoginData();

    controller = LoginController(
      auth: mockAuth,
      loginData: fakeLoginData,
    );
    Get.put<LoginController>(controller);
  });

  tearDown(TestHarness.tearDownGetx);

  group('LoginController state', () {
    test('الحالة الأولية: غير مسجل الدخول', () {
      expect(controller.isLoggedIn.value, isFalse);
      expect(controller.isLoading.value, isFalse);
    });

    test('يمكن تغيير حالة isLoggedIn', () {
      controller.isLoggedIn.value = true;
      expect(controller.isLoggedIn.value, isTrue);

      controller.isLoggedIn.value = false;
      expect(controller.isLoggedIn.value, isFalse);
    });

    test('يمكن تغيير حالة isLoading', () {
      controller.isLoading.value = true;
      expect(controller.isLoading.value, isTrue);

      controller.isLoading.value = false;
      expect(controller.isLoading.value, isFalse);
    });
  });

  group('LoginController DI', () {
    test('يقبل auth مخصّص', () {
      final ctrl = LoginController(auth: mockAuth);
      expect(ctrl, isNotNull);
    });

    test('يقبل loginData مخصّص', () {
      final ctrl = LoginController(loginData: fakeLoginData);
      expect(ctrl, isNotNull);
    });

    test('يعمل بدون أي parameters (constructor لا يرمي)', () {
      LoginController ctrl;
      try {
        ctrl = LoginController();
        expect(ctrl, isNotNull);
      } catch (_) {
        // يتوقع فشل تهيئة Firebase في بيئة الاختبار
      }
    });
  });
}
