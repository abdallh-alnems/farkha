import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/phone_verification_strings.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/services/initialization.dart';
import '../../../data/data_source/remote/auth_data/phone_verification_status_data.dart';
import '../../../data/data_source/remote/auth_data/resend_otp_data.dart';
import '../../../data/data_source/remote/auth_data/send_otp_data.dart';
import '../../../data/data_source/remote/auth_data/update_phone_data.dart';
import '../../../data/data_source/remote/auth_data/verify_otp_data.dart';
import '../../../data/model/phone_verification_model.dart';

class PhoneVerificationController extends GetxController {
  final SendOtpData _sendOtpData;
  final VerifyOtpData _verifyOtpData;
  final ResendOtpData _resendOtpData;
  final UpdatePhoneData _updatePhoneData;
  final PhoneVerificationStatusData _statusData;

  PhoneVerificationController({
    SendOtpData? sendOtpData,
    VerifyOtpData? verifyOtpData,
    ResendOtpData? resendOtpData,
    UpdatePhoneData? updatePhoneData,
    PhoneVerificationStatusData? statusData,
  })  : _sendOtpData = sendOtpData ?? SendOtpData(),
        _verifyOtpData = verifyOtpData ?? VerifyOtpData(),
        _resendOtpData = resendOtpData ?? ResendOtpData(),
        _updatePhoneData = updatePhoneData ?? UpdatePhoneData(),
        _statusData = statusData ?? PhoneVerificationStatusData();

  final status = StatusRequest.none.obs;
  final Rx<PhoneVerificationSession?> session = Rx<PhoneVerificationSession?>(null);
  final resendCountdown = 0.obs;
  final lockoutRemainingSeconds = 0.obs;
  final isResendEnabled = false.obs;
  final errorMessage = ''.obs;
  final phoneNumber = ''.obs;
  final verifiedToken = ''.obs;
  final pendingCooldownSeconds = 0.obs;
  final pendingCooldownMessage = ''.obs;
  final pendingCooldownPhone = ''.obs;

  Timer? _countdownTimer;
  Timer? _lockoutTimer;
  Timer? _pendingCooldownTimer;

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _lockoutTimer?.cancel();
    _pendingCooldownTimer?.cancel();
    super.onClose();
  }

  static const String _kCooldownUntilKey = 'phone_cooldown_until_ms';
  static const String _kCooldownPhoneKey = 'phone_cooldown_phone';

  String _formatCooldownMessage(int remaining) {
    final mins = remaining ~/ 60;
    return mins > 0
        ? 'انتظر $mins دقيقة قبل إعادة الإرسال'
        : 'انتظر $remaining ثانية قبل إعادة الإرسال';
  }

  void _saveCooldownToStorage(int retryAfterSeconds, String phone) {
    try {
      final until = DateTime.now().millisecondsSinceEpoch + retryAfterSeconds * 1000;
      final box = Get.find<MyServices>().getStorage;
      box.write(_kCooldownUntilKey, until);
      box.write(_kCooldownPhoneKey, phone);
    } catch (_) {}
  }

  void _clearCooldownStorage() {
    try {
      final box = Get.find<MyServices>().getStorage;
      box.remove(_kCooldownUntilKey);
      box.remove(_kCooldownPhoneKey);
    } catch (_) {}
  }

  void _startPendingCooldownTicker(int seconds) {
    _pendingCooldownTimer?.cancel();
    pendingCooldownSeconds.value = seconds;
    pendingCooldownMessage.value = _formatCooldownMessage(seconds);

    _pendingCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (pendingCooldownSeconds.value <= 1) {
        timer.cancel();
        pendingCooldownSeconds.value = 0;
        pendingCooldownMessage.value = '';
        _clearCooldownStorage();
      } else {
        pendingCooldownSeconds.value--;
        pendingCooldownMessage.value = _formatCooldownMessage(pendingCooldownSeconds.value);
      }
    });
  }

  void loadCachedCooldown() {
    try {
      final box = Get.find<MyServices>().getStorage;
      final until = box.read<int>(_kCooldownUntilKey);
      final phone = box.read<String>(_kCooldownPhoneKey) ?? '';
      if (until == null) return;
      final remaining = ((until - DateTime.now().millisecondsSinceEpoch) / 1000).floor();
      if (remaining > 0) {
        pendingCooldownPhone.value = phone;
        _startPendingCooldownTicker(remaining);
      } else {
        _clearCooldownStorage();
      }
    } catch (_) {}
  }

  Future<void> checkPendingCooldown() async {
    loadCachedCooldown();

    final token = await _getFirebaseToken();
    if (token == null) return;

    final response = await _statusData.fetchStatus(token: token);
    response.fold(
      (_) {},
      (Map<String, dynamic> result) {
        if (result['status'] != 'success' && result['success'] != true) return;
        final data = result['data'] as Map<String, dynamic>?;
        if (data == null) return;

        if (data['has_cooldown'] == true) {
          final retry = (data['retry_after_seconds'] as num?)?.toInt() ?? 0;
          final phone = data['phone'] as String? ?? '';
          pendingCooldownPhone.value = phone;
          if (retry > 0) {
            _saveCooldownToStorage(retry, phone);
            _startPendingCooldownTicker(retry);
          }
        } else {
          _pendingCooldownTimer?.cancel();
          pendingCooldownSeconds.value = 0;
          pendingCooldownMessage.value = '';
          pendingCooldownPhone.value = '';
          _clearCooldownStorage();
        }
      },
    );
  }

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

  Future<String?> _getFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }

  void _startResendCountdown(int seconds) {
    _countdownTimer?.cancel();
    resendCountdown.value = seconds;
    isResendEnabled.value = false;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value <= 1) {
        timer.cancel();
        isResendEnabled.value = true;
        resendCountdown.value = 0;
      } else {
        resendCountdown.value--;
      }
    });
  }

  void startResendCountdown(int seconds) => _startResendCountdown(seconds);

  void _startLockoutCountdown(int seconds) {
    _lockoutTimer?.cancel();
    lockoutRemainingSeconds.value = seconds;

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (lockoutRemainingSeconds.value <= 1) {
        timer.cancel();
        lockoutRemainingSeconds.value = 0;
      } else {
        lockoutRemainingSeconds.value--;
      }
    });
  }

  Future<void> sendOtp(String phone) async {
    final normalized = normalizePhone(phone);

    if (!RegExp(r'^\+201[0-9]{9}$').hasMatch(normalized)) {
      errorMessage.value = PhoneVerificationStrings.errorInvalidPhone;
      status.value = StatusRequest.none;
      return;
    }

    final token = await _getFirebaseToken();
    if (token == null) {
      errorMessage.value = 'يجب تسجيل الدخول أولاً';
      status.value = StatusRequest.none;
      return;
    }

    status.value = StatusRequest.loading;
    errorMessage.value = '';

    final response = await _sendOtpData.sendOtp(token: token, phone: normalized);

    response.fold(
      (failure) {
        status.value = failure;
        if (failure == StatusRequest.offlineFailure) {
          errorMessage.value = PhoneVerificationStrings.errorOffline;
        } else {
          errorMessage.value = PhoneVerificationStrings.errorServer;
        }
      },
      (Map<String, dynamic> result) {
        if (result['status'] == 'success' || result['success'] == true) {
          final data = result['data'] as Map<String, dynamic>?;
          if (data != null) {
            session.value = PhoneVerificationSession.fromJson({
              ...data,
              'phone': normalized,
            });
            phoneNumber.value = normalized;

            final resendAllowedAt = session.value?.resendAllowedAt;
            if (resendAllowedAt != null) {
              final diff = resendAllowedAt.difference(DateTime.now()).inSeconds;
              if (diff > 0) {
                _startResendCountdown(diff);
              } else {
                isResendEnabled.value = true;
              }
            }

            _pendingCooldownTimer?.cancel();
            pendingCooldownSeconds.value = 0;
            pendingCooldownMessage.value = '';
            _clearCooldownStorage();

            status.value = StatusRequest.success;
            Get.toNamed<void>(AppRoute.enterOtp);
          }
        } else {
          final error = result['error'] as Map<String, dynamic>?;
          final code = error?['code'] as String? ?? result['code'] as String? ?? '';
          switch (code) {
            case 'invalid_phone_format':
            case 'unsupported_country':
              status.value = StatusRequest.none;
              errorMessage.value = PhoneVerificationStrings.errorInvalidPhone;
              break;
            case 'phone_already_linked':
              status.value = StatusRequest.none;
              errorMessage.value = PhoneVerificationStrings.errorPhoneAlreadyLinked;
              break;
            case 'resend_cooldown':
              status.value = StatusRequest.none;
              errorMessage.value = '';
              final retry = (error?['retry_after_seconds'] as num?)?.toInt() ?? 0;
              if (retry > 0) {
                _saveCooldownToStorage(retry, phoneNumber.value);
                _startPendingCooldownTicker(retry);
              }
              break;
            case 'resend_limit_exceeded':
              status.value = StatusRequest.none;
              errorMessage.value = PhoneVerificationStrings.errorResendLimit;
              break;
            case 'whatsapp_send_failed':
              status.value = StatusRequest.failure;
              errorMessage.value = PhoneVerificationStrings.errorWhatsappFailed;
              break;
            default:
              status.value = StatusRequest.failure;
              errorMessage.value = error?['message'] as String? ?? PhoneVerificationStrings.errorServer;
          }
        }
      },
    );
  }

  Future<void> verifyOtp(String code) async {
    if (session.value == null) {
      errorMessage.value = PhoneVerificationStrings.errorSessionExpired;
      status.value = StatusRequest.failure;
      return;
    }

    if (code.length != 6) return;

    final token = await _getFirebaseToken();
    if (token == null) {
      errorMessage.value = 'يجب تسجيل الدخول أولاً';
      status.value = StatusRequest.failure;
      return;
    }

    status.value = StatusRequest.loading;
    errorMessage.value = '';

    final response = await _verifyOtpData.verifyOtp(
      token: token,
      sessionToken: session.value!.sessionToken,
      otpCode: code,
    );

    response.fold(
      (failure) {
        status.value = failure;
        if (failure == StatusRequest.offlineFailure) {
          errorMessage.value = PhoneVerificationStrings.errorOffline;
        } else {
          errorMessage.value = PhoneVerificationStrings.errorServer;
        }
      },
      (Map<String, dynamic> result) {
        if (result['status'] == 'success' || result['success'] == true) {
          final data = result['data'] as Map<String, dynamic>?;
          if (data != null) {
            final vt = data['verified_token'];
            if (vt is String && vt.isNotEmpty) {
              verifiedToken.value = vt;
              _updatePhoneWithVerifiedToken();
            } else {
              status.value = StatusRequest.failure;
              errorMessage.value = PhoneVerificationStrings.errorServer;
            }
          }
        } else {
          final error = result['error'] as Map<String, dynamic>?;
          final code = error?['code'] as String? ?? result['code'] as String? ?? '';
          switch (code) {
            case 'wrong_otp':
              status.value = StatusRequest.failure;
              final remaining = error?['attempts_remaining'] as int? ?? 0;
              errorMessage.value =
                  '${PhoneVerificationStrings.errorWrongOtp}. ${PhoneVerificationStrings.attemptsRemaining}: $remaining';
              if (session.value != null) {
                session.value = session.value!.copyWith(attemptsRemaining: remaining);
              }
              break;
            case 'session_locked':
              status.value = StatusRequest.failure;
              errorMessage.value = PhoneVerificationStrings.errorSessionLocked;
              final retryAfter = error?['retry_after_seconds'] as int? ?? 900;
              _startLockoutCountdown(retryAfter);
              break;
            case 'session_expired':
              status.value = StatusRequest.failure;
              errorMessage.value = PhoneVerificationStrings.errorSessionExpired;
              break;
            default:
              status.value = StatusRequest.failure;
              errorMessage.value = error?['message'] as String? ?? PhoneVerificationStrings.errorServer;
          }
        }
      },
    );
  }

  Future<void> _updatePhoneWithVerifiedToken() async {
    final token = await _getFirebaseToken();
    if (token == null) {
      errorMessage.value = 'يجب تسجيل الدخول أولاً';
      status.value = StatusRequest.failure;
      return;
    }

    final response = await _updatePhoneData.updatePhone(
      token: token,
      verifiedToken: verifiedToken.value,
    );

    response.fold(
      (failure) {
        status.value = failure;
        if (failure == StatusRequest.offlineFailure) {
          errorMessage.value = PhoneVerificationStrings.errorOffline;
        } else {
          errorMessage.value = PhoneVerificationStrings.errorServer;
        }
      },
      (Map<String, dynamic> result) {
        if (result['status'] == 'success' || result['success'] == true) {
          final data = result['data'] as Map<String, dynamic>?;
          final phone = data?['phone'] as String? ?? phoneNumber.value;

          final myServices = Get.find<MyServices>();
          myServices.getStorage.write('user_phone', phone);
          myServices.getStorage.write('phone_verified', true);

          status.value = StatusRequest.success;
          Get.until((route) => route.settings.name == AppRoute.home || route.isFirst);
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
        } else {
          final error = result['error'] as Map<String, dynamic>?;
          final code = error?['code'] as String? ?? '';
          if (code == 'phone_already_linked') {
            errorMessage.value = PhoneVerificationStrings.errorPhoneAlreadyLinked;
          } else {
            errorMessage.value = error?['message'] as String? ?? PhoneVerificationStrings.errorServer;
          }
          status.value = StatusRequest.failure;
        }
      },
    );
  }

  Future<void> resendOtp() async {
    if (session.value == null || !isResendEnabled.value) return;

    final token = await _getFirebaseToken();
    if (token == null) {
      errorMessage.value = 'يجب تسجيل الدخول أولاً';
      status.value = StatusRequest.failure;
      return;
    }

    status.value = StatusRequest.loading;
    errorMessage.value = '';

    final response = await _resendOtpData.resendOtp(
      token: token,
      sessionToken: session.value!.sessionToken,
    );

    response.fold(
      (failure) {
        status.value = failure;
        if (failure == StatusRequest.offlineFailure) {
          errorMessage.value = PhoneVerificationStrings.errorOffline;
        } else {
          errorMessage.value = PhoneVerificationStrings.errorServer;
        }
      },
      (Map<String, dynamic> result) {
        if (result['status'] == 'success' || result['success'] == true) {
          final data = result['data'] as Map<String, dynamic>?;
          if (data != null && session.value != null) {
            final expiresAt = DateTime.tryParse(data['expires_at'] as String? ?? '');
            final resendAllowedAt = DateTime.tryParse(data['resend_allowed_at'] as String? ?? '');
            session.value = session.value!.copyWith(
              expiresAt: expiresAt ?? session.value!.expiresAt,
              resendAllowedAt: resendAllowedAt,
            );
          }
          final resendAllowedAt = session.value?.resendAllowedAt;
          if (resendAllowedAt != null) {
            final diff = resendAllowedAt.difference(DateTime.now()).inSeconds;
            _startResendCountdown(diff > 0 ? diff : 30);
          }
          status.value = StatusRequest.success;
        } else {
          status.value = StatusRequest.failure;
          final error = result['error'] as Map<String, dynamic>?;
          final code = error?['code'] as String? ?? '';
          if (code == 'resend_limit_exceeded') {
            errorMessage.value = PhoneVerificationStrings.errorResendLimit;
            isResendEnabled.value = false;
          } else {
            errorMessage.value = error?['message'] as String? ?? PhoneVerificationStrings.errorServer;
          }
        }
      },
    );
  }

  void _showSnackbar(String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}
