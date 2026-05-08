import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/phone_verification_strings.dart';
import '../../../core/constant/theme/theme.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = Get.find<PhoneVerificationController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerHighest,
              isDark
                  ? const Color(0xFF201C16)
                  : AppColors.lightPageBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: () => Get.back<void>(),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          colorScheme.onSurface.withValues(alpha: 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                      ),
                    ),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 22.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => HandlingDataView(
                      statusRequest:
                          controller.status.value == StatusRequest.loading
                              ? StatusRequest.loading
                              : StatusRequest.success,
                      widget: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Column(
                          children: [
                            _buildLockIcon(colorScheme),
                            SizedBox(height: 20.h),
                            Text(
                              PhoneVerificationStrings.enterOtpTitle,
                              style: theme.textTheme.headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              PhoneVerificationStrings.codeSentTo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 6.h),
                            _buildPhonePill(theme, colorScheme, controller),
                            SizedBox(height: 32.h),
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
                            _buildStatusBanner(theme, colorScheme, controller),
                            _buildAttemptsIndicator(
                              theme,
                              colorScheme,
                              controller,
                            ),
                            SizedBox(height: 20.h),
                            ResendCountdownButton(
                              onResend: () => controller.resendOtp(),
                            ),
                            SizedBox(height: 12.h),
                            _buildWhatsAppHint(theme, colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockIcon(ColorScheme colorScheme) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Icon(
        Icons.lock_outline_rounded,
        size: 28.sp,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildPhonePill(
    ThemeData theme,
    ColorScheme colorScheme,
    PhoneVerificationController controller,
  ) {
    return Obx(() {
      final phone = controller.phoneNumber.value;
      final display =
          phone.startsWith('+20') ? '0${phone.substring(3)}' : phone;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.phone_android_rounded,
                size: 14.sp,
                color: colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                display,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  letterSpacing: 0.5.w,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatusBanner(
    ThemeData theme,
    ColorScheme colorScheme,
    PhoneVerificationController controller,
  ) {
    return Obx(() {
      if (controller.errorMessage.value.isNotEmpty &&
          controller.status.value != StatusRequest.loading) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: colorScheme.error.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 18.sp,
                color: colorScheme.error,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  controller.errorMessage.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (controller.lockoutRemainingSeconds.value > 0) {
        final minutes = controller.lockoutRemainingSeconds.value ~/ 60;
        final seconds = controller.lockoutRemainingSeconds.value % 60;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: AppColors.warningColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lock_clock_rounded,
                size: 18.sp,
                color: AppColors.warningColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${PhoneVerificationStrings.errorSessionLocked}. ${PhoneVerificationStrings.lockedMessage} $minutes:${seconds.toString().padLeft(2, '0')} ${PhoneVerificationStrings.minutesLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.warningColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildAttemptsIndicator(
    ThemeData theme,
    ColorScheme colorScheme,
    PhoneVerificationController controller,
  ) {
    return Obx(() {
      final session = controller.session.value;
      if (session == null || session.attemptsRemaining >= 5) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            SizedBox(width: 4.w),
            Text(
              '${PhoneVerificationStrings.attemptsRemaining}: ${session.attemptsRemaining}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWhatsAppHint(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.chat_bubble_rounded,
          size: 14.sp,
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        SizedBox(width: 4.w),
        Text(
          'تم الإرسال عبر واتساب',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}
