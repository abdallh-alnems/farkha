import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/phone_verification_strings.dart';
import '../../../core/constant/storage_keys.dart';
import '../../../core/services/initialization.dart';

String normalizePhone(String raw) {
  final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  final englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  var cleaned = raw;
  for (var i = 0; i < arabicDigits.length; i++) {
    cleaned = cleaned.replaceAll(arabicDigits[i], englishDigits[i]);
  }
  cleaned = cleaned.replaceAll(RegExp(r'[^0-9]'), '');

  if (cleaned.startsWith('201') && cleaned.length == 12) {
    return '+$cleaned';
  }
  if (cleaned.startsWith('01') && cleaned.length == 11) {
    return '+2$cleaned';
  }
  return '+20$cleaned';
}

bool isValidEgyptPhone(String phone) {
  final normalized = normalizePhone(phone);
  return RegExp(r'^\+201[0-9]{9}$').hasMatch(normalized);
}

String formatCooldownMessage(int remaining) {
  final mins = remaining ~/ 60;
  return mins > 0
      ? 'انتظر $mins دقيقة قبل إعادة الإرسال'
      : 'انتظر $remaining ثانية قبل إعادة الإرسال';
}

void saveCooldownToStorage(int retryAfterSeconds, String phone) {
  try {
    final until =
        DateTime.now().millisecondsSinceEpoch + retryAfterSeconds * 1000;
    final box = Get.find<MyServices>().getStorage;
    box.write(StorageKeys.phoneCooldownUntilMs, until);
    box.write(StorageKeys.phoneCooldownPhone, phone);
  } catch (_) {}
}

void clearCooldownStorage() {
  try {
    final box = Get.find<MyServices>().getStorage;
    box.remove(StorageKeys.phoneCooldownUntilMs);
    box.remove(StorageKeys.phoneCooldownPhone);
  } catch (_) {}
}

Future<String?> getFirebaseToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return user.getIdToken();
}

({int remaining, String phone})? loadCachedCooldownData() {
  try {
    final box = Get.find<MyServices>().getStorage;
    final until = box.read<int>(StorageKeys.phoneCooldownUntilMs);
    final phone = box.read<String>(StorageKeys.phoneCooldownPhone) ?? '';
    if (until == null) return null;
    final remaining =
        ((until - DateTime.now().millisecondsSinceEpoch) / 1000).floor();
    if (remaining > 0) {
      return (remaining: remaining, phone: phone);
    }
    clearCooldownStorage();
    return null;
  } catch (_) {
    return null;
  }
}

Timer createCountdownTimer({
  required int startSeconds,
  required void Function(int remaining) onTick,
  required void Function() onComplete,
}) {
  var remaining = startSeconds;
  return Timer.periodic(const Duration(seconds: 1), (timer) {
    if (remaining <= 1) {
      timer.cancel();
      onComplete();
    } else {
      remaining--;
      onTick(remaining);
    }
  });
}

({StatusRequest status, String message}) handleApiFailure(
    StatusRequest failure) {
  return (
    status: failure,
    message: failure == StatusRequest.offlineFailure
        ? PhoneVerificationStrings.errorOffline
        : PhoneVerificationStrings.errorServer,
  );
}

void showVerificationSuccessSnackbar() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = Get.context;
    if (ctx == null) return;
    final messenger = ScaffoldMessenger.maybeOf(ctx);
    messenger?.showSnackBar(
      SnackBar(
        content: const Text(
          'تم توثيق رقم الهاتف بنجاح',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  });
}

({StatusRequest status, String message, int? cooldownRetrySeconds})
    parseSendOtpError(Map<String, dynamic> result) {
  final error = result['error'] as Map<String, dynamic>?;
  final code = error?['code'] as String? ?? result['code'] as String? ?? '';
  return switch (code) {
    'invalid_phone_format' || 'unsupported_country' => (
        status: StatusRequest.none,
        message: PhoneVerificationStrings.errorInvalidPhone,
        cooldownRetrySeconds: null,
      ),
    'phone_already_linked' => (
        status: StatusRequest.none,
        message: PhoneVerificationStrings.errorPhoneAlreadyLinked,
        cooldownRetrySeconds: null,
      ),
    'resend_cooldown' => (
        status: StatusRequest.none,
        message: '',
        cooldownRetrySeconds:
            (error?['retry_after_seconds'] as num?)?.toInt() ?? 0,
      ),
    'resend_limit_exceeded' => (
        status: StatusRequest.none,
        message: PhoneVerificationStrings.errorResendLimit,
        cooldownRetrySeconds: null,
      ),
    'whatsapp_send_failed' => (
        status: StatusRequest.failure,
        message: PhoneVerificationStrings.errorWhatsappFailed,
        cooldownRetrySeconds: null,
      ),
    _ => (
        status: StatusRequest.failure,
        message: error?['message'] as String? ??
            PhoneVerificationStrings.errorServer,
        cooldownRetrySeconds: null,
      ),
  };
}

({StatusRequest status, String message, int? attemptsRemaining, int? lockoutSeconds})
    parseVerifyOtpError(Map<String, dynamic> result) {
  final error = result['error'] as Map<String, dynamic>?;
  final code = error?['code'] as String? ?? result['code'] as String? ?? '';
  return switch (code) {
    'wrong_otp' => (
        status: StatusRequest.failure,
        message:
            '${PhoneVerificationStrings.errorWrongOtp}. ${PhoneVerificationStrings.attemptsRemaining}: ${error?['attempts_remaining'] as int? ?? 0}',
        attemptsRemaining: error?['attempts_remaining'] as int?,
        lockoutSeconds: null,
      ),
    'session_locked' => (
        status: StatusRequest.failure,
        message: PhoneVerificationStrings.errorSessionLocked,
        attemptsRemaining: null,
        lockoutSeconds: error?['retry_after_seconds'] as int? ?? 900,
      ),
    'session_expired' => (
        status: StatusRequest.failure,
        message: PhoneVerificationStrings.errorSessionExpired,
        attemptsRemaining: null,
        lockoutSeconds: null,
      ),
    _ => (
        status: StatusRequest.failure,
        message: error?['message'] as String? ??
            PhoneVerificationStrings.errorServer,
        attemptsRemaining: null,
        lockoutSeconds: null,
      ),
  };
}

void showOtpSnackbar(String message) {
  Get.snackbar(
    '',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green.withValues(alpha: 0.9),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
  );
}
