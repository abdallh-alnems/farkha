import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/phone_verification_strings.dart';
import '../../../logic/controller/auth/phone_verification_controller.dart';
import '../../widget/auth/otp_input_field.dart';
import '../../widget/auth/resend_countdown_button.dart';

class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({super.key});

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final _otpCode = ''.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<PhoneVerificationController>();
      if (controller.session.value?.resendAllowedAt != null) {
        final diff = controller.session.value!.resendAllowedAt!
            .difference(DateTime.now())
            .inSeconds;
        if (diff > 0) {
          controller.startResendCountdown(diff);
        } else {
          controller.isResendEnabled.value = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhoneVerificationController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          PhoneVerificationStrings.enterOtpTitle,
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
      body: Obx(() {
        return HandlingDataView(
          statusRequest: controller.status.value == StatusRequest.loading
              ? StatusRequest.loading
              : StatusRequest.success,
          widget: SingleChildScrollView(
            padding: EdgeInsetsDirectional.fromSTEB(24.w, 32.h, 24.w, 24.h),
            child: Column(
              children: [
                Text(
                  '${PhoneVerificationStrings.codeSentTo}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(() {
                  final phone = controller.phoneNumber.value;
                  final display = phone.startsWith('+20')
                      ? '0${phone.substring(3)}'
                      : phone;
                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      display,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }),
                SizedBox(height: 40.h),
                OtpInputField(
                  onCompleted: (code) {
                    _otpCode.value = code;
                    controller.verifyOtp(code);
                  },
                  onChanged: (code) {
                    _otpCode.value = code;
                  },
                ),
                SizedBox(height: 16.h),
                Obx(() {
                  if (controller.errorMessage.value.isNotEmpty &&
                      controller.status.value != StatusRequest.loading) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (controller.lockoutRemainingSeconds.value > 0) {
                    final minutes = controller.lockoutRemainingSeconds.value ~/ 60;
                    final seconds = controller.lockoutRemainingSeconds.value % 60;
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${PhoneVerificationStrings.errorSessionLocked}. ${PhoneVerificationStrings.lockedMessage} $minutes:${seconds.toString().padLeft(2, '0')} ${PhoneVerificationStrings.minutesLabel}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.amber.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                SizedBox(height: 24.h),
                Obx(() {
                  final session = controller.session.value;
                  if (session != null && session.attemptsRemaining < 5) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        '${PhoneVerificationStrings.attemptsRemaining}: ${session.attemptsRemaining}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                ResendCountdownButton(
                  onResend: () => controller.resendOtp(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

}
