import 'package:farkha_app/logic/controller/auth/phone_verification_controller.dart';
import 'package:farkha_app/logic/controller/auth/phone_verification_helpers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../helpers/test_harness.dart';

void main() {
  setUp(TestHarness.setUpGetx);
  tearDown(TestHarness.tearDownGetx);

  group('normalizePhone', () {
    test('يُحوّل الرقم المصري القصير (01...) إلى +2...', () {
      final result = normalizePhone('01012345678');

      expect(result, '+201012345678');
    });

    test('يُحوّل الرقم بدون + (201...) إلى +201...', () {
      final result = normalizePhone('201012345678');

      expect(result, '+201012345678');
    });

    test('يُحوّل الأرقام العربية إلى إنجليزية', () {
      final result = normalizePhone('٠١٠١٢٣٤٥٦٧٨');

      expect(result, '+201012345678');
    });

    test('يُزيل المسافات والشرطات', () {
      final result = normalizePhone('010-123 45678');

      expect(result, '+201012345678');
    });
  });

  group('isValidEgyptPhone', () {
    test('رقم مصري صحيح يبدأ بـ 010', () {
      expect(isValidEgyptPhone('01012345678'), isTrue);
    });

    test('رقم مصري صحيح يبدأ بـ 011', () {
      expect(isValidEgyptPhone('01112345678'), isTrue);
    });

    test('رقم مصري صحيح يبدأ بـ 012', () {
      expect(isValidEgyptPhone('01212345678'), isTrue);
    });

    test('رقم مصري صحيح يبدأ بـ 015', () {
      expect(isValidEgyptPhone('01512345678'), isTrue);
    });

    test('رقم قصير جداً غير صحيح', () {
      expect(isValidEgyptPhone('010123456'), isFalse);
    });

    test('رقم أجنبي غير صحيح', () {
      expect(isValidEgyptPhone('+14155552671'), isFalse);
    });

    test('سلسلة فارغة غير صحيحة', () {
      expect(isValidEgyptPhone(''), isFalse);
    });
  });

  group('PhoneVerificationController state', () {
    test('الحالة الابتدائية', () {
      final controller = PhoneVerificationController();
      Get.put<PhoneVerificationController>(controller);

      expect(controller.resendCountdown.value, 0);
      expect(controller.lockoutRemainingSeconds.value, 0);
      expect(controller.isResendEnabled.value, isFalse);
      expect(controller.errorMessage.value, '');
      expect(controller.phoneNumber.value, '');
      expect(controller.verifiedToken.value, '');
    });

    test('startResendCountdown يبدأ العد التنازلي', () async {
      final controller = PhoneVerificationController();
      Get.put<PhoneVerificationController>(controller);

      controller.startResendCountdown(2);

      expect(controller.resendCountdown.value, 2);
      expect(controller.isResendEnabled.value, isFalse);

      await Future.delayed(const Duration(seconds: 3));

      expect(controller.resendCountdown.value, 0);
      expect(controller.isResendEnabled.value, isTrue);
    });
  });
}
