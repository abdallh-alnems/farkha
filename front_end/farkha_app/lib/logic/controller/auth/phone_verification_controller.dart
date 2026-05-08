import 'dart:async';

import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/phone_verification_strings.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/storage_keys.dart';
import '../../../core/services/initialization.dart';
import '../../../data/data_source/remote/auth_data/phone_verification_status_data.dart';
import '../../../data/data_source/remote/auth_data/resend_otp_data.dart';
import '../../../data/data_source/remote/auth_data/send_otp_data.dart';
import '../../../data/data_source/remote/auth_data/update_phone_data.dart';
import '../../../data/data_source/remote/auth_data/verify_otp_data.dart';
import '../../../data/model/phone_verification_model.dart';
import 'phone_verification_helpers.dart';

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
  final Rx<PhoneVerificationSession?> session =
      Rx<PhoneVerificationSession?>(null);
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

  void _startPendingCooldownTicker(int seconds) {
    _pendingCooldownTimer?.cancel();
    pendingCooldownSeconds.value = seconds;
    pendingCooldownMessage.value = formatCooldownMessage(seconds);

    _pendingCooldownTimer = createCountdownTimer(
      startSeconds: seconds,
      onTick: (r) {
        pendingCooldownSeconds.value = r;
        pendingCooldownMessage.value = formatCooldownMessage(r);
      },
      onComplete: () {
        pendingCooldownSeconds.value = 0;
        pendingCooldownMessage.value = '';
        clearCooldownStorage();
      },
    );
  }

  void loadCachedCooldown() {
    final cached = loadCachedCooldownData();
    if (cached == null) return;
    pendingCooldownPhone.value = cached.phone;
    _startPendingCooldownTicker(cached.remaining);
  }

  Future<void> checkPendingCooldown() async {
    loadCachedCooldown();

    final token = await getFirebaseToken();
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
            saveCooldownToStorage(retry, phone);
            _startPendingCooldownTicker(retry);
          }
        } else {
          _pendingCooldownTimer?.cancel();
          pendingCooldownSeconds.value = 0;
          pendingCooldownMessage.value = '';
          pendingCooldownPhone.value = '';
          clearCooldownStorage();
        }
      },
    );
  }

  void _startResendCountdown(int seconds) {
    _countdownTimer?.cancel();
    resendCountdown.value = seconds;
    isResendEnabled.value = false;

    _countdownTimer = createCountdownTimer(
      startSeconds: seconds,
      onTick: (r) => resendCountdown.value = r,
      onComplete: () {
        isResendEnabled.value = true;
        resendCountdown.value = 0;
      },
    );
  }

  void startResendCountdown(int seconds) => _startResendCountdown(seconds);

  void _startLockoutCountdown(int seconds) {
    _lockoutTimer?.cancel();
    lockoutRemainingSeconds.value = seconds;

    _lockoutTimer = createCountdownTimer(
      startSeconds: seconds,
      onTick: (r) => lockoutRemainingSeconds.value = r,
      onComplete: () => lockoutRemainingSeconds.value = 0,
    );
  }

  Future<void> sendOtp(String phone) async {
    final normalized = normalizePhone(phone);

    if (!RegExp(r'^\+201[0-9]{9}$').hasMatch(normalized)) {
      errorMessage.value = PhoneVerificationStrings.errorInvalidPhone;
      status.value = StatusRequest.none;
      return;
    }

    final token = await getFirebaseToken();
    if (token == null) {
      errorMessage.value = 'يجب تسجيل الدخول أولاً';
      status.value = StatusRequest.none;
      return;
    }

    status.value = StatusRequest.loading;
    errorMessage.value = '';

    final response =
        await _sendOtpData.sendOtp(token: token, phone: normalized);

    response.fold(
      (failure) {
        final f = handleApiFailure(failure);
        status.value = f.status;
        errorMessage.value = f.message;
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
              final diff =
                  resendAllowedAt.difference(DateTime.now()).inSeconds;
              if (diff > 0) {
                _startResendCountdown(diff);
              } else {
                isResendEnabled.value = true;
              }
            }

            _pendingCooldownTimer?.cancel();
            pendingCooldownSeconds.value = 0;
            pendingCooldownMessage.value = '';
            clearCooldownStorage();

            status.value = StatusRequest.success;
            Get.toNamed<void>(AppRoute.enterOtp);
          }
        } else {
          final err = parseSendOtpError(result);
          status.value = err.status;
          errorMessage.value = err.message;
          final retry = err.cooldownRetrySeconds;
          if (retry != null && retry > 0) {
            saveCooldownToStorage(retry, phoneNumber.value);
            _startPendingCooldownTicker(retry);
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

    final token = await getFirebaseToken();
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
        final f = handleApiFailure(failure);
        status.value = f.status;
        errorMessage.value = f.message;
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
          final err = parseVerifyOtpError(result);
          status.value = err.status;
          errorMessage.value = err.message;
          if (err.attemptsRemaining != null && session.value != null) {
            session.value = session.value!
                .copyWith(attemptsRemaining: err.attemptsRemaining!);
          }
          if (err.lockoutSeconds != null) {
            _startLockoutCountdown(err.lockoutSeconds!);
          }
        }
      },
    );
  }

  Future<void> _updatePhoneWithVerifiedToken() async {
    final token = await getFirebaseToken();
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
        final f = handleApiFailure(failure);
        status.value = f.status;
        errorMessage.value = f.message;
      },
      (Map<String, dynamic> result) {
        if (result['status'] == 'success' || result['success'] == true) {
          final data = result['data'] as Map<String, dynamic>?;
          final phone = data?['phone'] as String? ?? phoneNumber.value;

          final myServices = Get.find<MyServices>();
          myServices.getStorage.write(StorageKeys.userPhone, phone);
          myServices.getStorage.write(StorageKeys.phoneVerified, true);

          Get.until(
              (route) => route.settings.name == AppRoute.home || route.isFirst);
          status.value = StatusRequest.none;
          showVerificationSuccessSnackbar();
        } else {
          final error = result['error'] as Map<String, dynamic>?;
          final code = error?['code'] as String? ?? '';
          if (code == 'phone_already_linked') {
            errorMessage.value =
                PhoneVerificationStrings.errorPhoneAlreadyLinked;
          } else {
            errorMessage.value = error?['message'] as String? ??
                PhoneVerificationStrings.errorServer;
          }
          status.value = StatusRequest.failure;
        }
      },
    );
  }

  Future<void> resendOtp() async {
    if (session.value == null || !isResendEnabled.value) return;

    final token = await getFirebaseToken();
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
        final f = handleApiFailure(failure);
        status.value = f.status;
        errorMessage.value = f.message;
      },
      (Map<String, dynamic> result) {
        if (result['status'] == 'success' || result['success'] == true) {
          final data = result['data'] as Map<String, dynamic>?;
          if (data != null && session.value != null) {
            final expiresAt =
                DateTime.tryParse(data['expires_at'] as String? ?? '');
            final resendAllowedAt =
                DateTime.tryParse(data['resend_allowed_at'] as String? ?? '');
            session.value = session.value!.copyWith(
              expiresAt: expiresAt ?? session.value!.expiresAt,
              resendAllowedAt: resendAllowedAt,
            );
          }
          final resendAllowedAt = session.value?.resendAllowedAt;
          if (resendAllowedAt != null) {
            final diff =
                resendAllowedAt.difference(DateTime.now()).inSeconds;
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
            errorMessage.value = error?['message'] as String? ??
                PhoneVerificationStrings.errorServer;
          }
        }
      },
    );
  }
}
