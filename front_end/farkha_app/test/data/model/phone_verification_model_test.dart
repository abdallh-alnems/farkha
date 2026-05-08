import 'package:farkha_app/data/model/phone_verification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneVerificationSession', () {
    test('fromJson يُنشئ كائن صحيح', () {
      final json = {
        'session_token': 'tok123',
        'phone': '+201012345678',
        'expires_at': '2026-06-01T00:00:00Z',
        'attempts_remaining': 5,
        'resend_allowed_at': '2026-05-01T00:00:00Z',
      };

      final session = PhoneVerificationSession.fromJson(json);

      expect(session.sessionToken, 'tok123');
      expect(session.phoneNumber, '+201012345678');
      expect(session.attemptsRemaining, 5);
      expect(session.resendAllowedAt, DateTime.parse('2026-05-01T00:00:00Z'));
    });

    test('fromJson بدون resend_allowed_at', () {
      final json = {
        'session_token': 'tok123',
        'phone': '+201012345678',
        'expires_at': '2026-06-01T00:00:00Z',
      };

      final session = PhoneVerificationSession.fromJson(json);

      expect(session.resendAllowedAt, isNull);
      expect(session.attemptsRemaining, 5);
    });

    test('toJson يُرجع خريطة صحيحة', () {
      final session = PhoneVerificationSession(
        sessionToken: 'tok123',
        phoneNumber: '+201012345678',
        expiresAt: DateTime.parse('2026-06-01T00:00:00Z'),
        attemptsRemaining: 3,
        resendAllowedAt: DateTime.parse('2026-05-01T00:00:00Z'),
      );

      final json = session.toJson();

      expect(json['session_token'], 'tok123');
      expect(json['phone'], '+201012345678');
      expect(json['attempts_remaining'], 3);
      expect(json['resend_allowed_at'], '2026-05-01T00:00:00.000Z');
    });

    test('toJson بدون resend_allowed_at يُرجع null', () {
      final session = PhoneVerificationSession(
        sessionToken: 'tok123',
        phoneNumber: '+201012345678',
        expiresAt: DateTime.parse('2026-06-01T00:00:00Z'),
        attemptsRemaining: 3,
      );

      final json = session.toJson();

      expect(json['resend_allowed_at'], isNull);
    });

    test('copyWith يُغيّر الحقول المحددة فقط', () {
      final session = PhoneVerificationSession(
        sessionToken: 'tok123',
        phoneNumber: '+201012345678',
        expiresAt: DateTime.parse('2026-06-01T00:00:00Z'),
        attemptsRemaining: 5,
      );

      final copied = session.copyWith(attemptsRemaining: 2);

      expect(copied.sessionToken, 'tok123');
      expect(copied.attemptsRemaining, 2);
      expect(copied.phoneNumber, '+201012345678');
    });
  });

  group('PhoneVerificationResult', () {
    test('fromJson يُنشئ كائن صحيح', () {
      final json = {
        'verified_token': 'vt123',
        'verified_token_expires_at': '2026-06-01T00:00:00Z',
        'phone': '+201012345678',
      };

      final result = PhoneVerificationResult.fromJson(json);

      expect(result.verifiedToken, 'vt123');
      expect(result.phoneNumber, '+201012345678');
    });

    test('toJson يُرجع خريطة صحيحة', () {
      final result = PhoneVerificationResult(
        verifiedToken: 'vt123',
        verifiedTokenExpiresAt: DateTime.parse('2026-06-01T00:00:00Z'),
        phoneNumber: '+201012345678',
      );

      final json = result.toJson();

      expect(json['verified_token'], 'vt123');
      expect(json['phone'], '+201012345678');
    });
  });
}
