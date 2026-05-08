import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/constant/phone_verification_strings.dart';
import '../../../core/constant/storage_keys.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../core/services/initialization.dart';
import '../../../core/shared/buttons/app_button.dart';
import '../../../core/shared/dialogs/app_alert_dialog.dart';
import '../../../logic/controller/auth/phone_verification_controller.dart';
import '../../widget/auth/country_prefix_label.dart';
import '../../widget/auth/phone_input_field.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  const VerifyPhoneNumberScreen({super.key});

  @override
  State<VerifyPhoneNumberScreen> createState() =>
      _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> {
  final _phoneController = TextEditingController();
  late final PhoneVerificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(PhoneVerificationController());
    _controller.loadCachedCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.checkPendingCooldown();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
                      statusRequest: _controller.status.value,
                      widget: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Column(
                          children: [
                            _buildPhoneIcon(colorScheme),
                            SizedBox(height: 24.h),
                            Text(
                              PhoneVerificationStrings.screenTitle,
                              style: theme.textTheme.displaySmall,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'سجّل رقمك لتأكيد هويتك وحماية حسابك',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32.h),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                children: [
                                  const CountryPrefixLabel(),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: PhoneInputField(
                                      controller: _phoneController,
                                      errorText: _controller
                                              .errorMessage.value.isNotEmpty
                                          ? _controller.errorMessage.value
                                          : null,
                                      onChanged: (_) {
                                        if (_controller
                                            .errorMessage.value.isNotEmpty) {
                                          _controller.errorMessage.value = '';
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),
                            _buildActionSection(theme, colorScheme),
                            SizedBox(height: 20.h),
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

  Widget _buildPhoneIcon(ColorScheme colorScheme) {
    return SizedBox(
      width: 80.w,
      height: 80.w,
      child: Stack(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.phone_android_rounded,
              size: 34.sp,
              color: colorScheme.primary,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 26.w,
              height: 26.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.tertiary,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
              child: Icon(
                Icons.shield_rounded,
                size: 14.sp,
                color: colorScheme.onTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(ThemeData theme, ColorScheme colorScheme) {
    return Obx(() {
      final cooldown = _controller.pendingCooldownSeconds.value;
      final cooldownMsg = _controller.pendingCooldownMessage.value;
      final hasCooldown = cooldown > 0 && cooldownMsg.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasCooldown) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20.sp,
                    color: colorScheme.error,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      cooldownMsg,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  Text(
                    cooldown >= 60
                        ? '${(cooldown ~/ 60).toString().padLeft(2, '0')}:${(cooldown % 60).toString().padLeft(2, '0')}'
                        : '$cooldown',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
          AppButton(
            label: PhoneVerificationStrings.sendOtpButton,
            onPressed: hasCooldown ? null : () => _handleSend(),
          ),
        ],
      );
    });
  }

  Widget _buildWhatsAppHint(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.chat_bubble_rounded,
          size: 16.sp,
          color: colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        SizedBox(width: 6.w),
        Text(
          'سيتم إرسال الرمز عبر واتساب',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  void _handleSend() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _controller.errorMessage.value =
          PhoneVerificationStrings.errorInvalidPhone;
      return;
    }

    final myServices = Get.find<MyServices>();
    final currentPhone =
        myServices.getStorage.read<String>(StorageKeys.userPhone);
    final hasVerifiedPhone =
        myServices.getStorage.read<bool>(StorageKeys.phoneVerified) ?? false;

    if (currentPhone != null &&
        currentPhone.isNotEmpty &&
        hasVerifiedPhone) {
      _showReplaceDialog(() {
        _controller.sendOtp(phone);
      });
    } else {
      _controller.sendOtp(phone);
    }
  }

  void _showReplaceDialog(VoidCallback onConfirm) {
    Get.dialog<bool>(
      AppAlertDialog(
        icon: Icons.swap_horiz_rounded,
        iconColor: Get.theme.colorScheme.tertiary,
        title: PhoneVerificationStrings.changePhoneAction,
        description: PhoneVerificationStrings.replacePhoneConfirm,
        primaryActionLabel: PhoneVerificationStrings.confirm,
        primaryAction: () {
          Get.back(result: true);
          onConfirm();
        },
        secondaryActionLabel: PhoneVerificationStrings.cancel,
        secondaryAction: () => Get.back(result: false),
      ),
    );
  }
}
