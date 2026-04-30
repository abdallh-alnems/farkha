import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/constant/phone_verification_strings.dart';
import '../../../core/constant/storage_keys.dart';
import '../../../core/services/initialization.dart';
import '../../../logic/controller/auth/phone_verification_controller.dart';
import '../../widget/auth/country_prefix_label.dart';
import '../../widget/auth/phone_input_field.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  const VerifyPhoneNumberScreen({super.key});

  @override
  State<VerifyPhoneNumberScreen> createState() => _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          PhoneVerificationStrings.screenTitle,
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
      body: Obx(() {
        return HandlingDataView(
          statusRequest: controller.status.value,
          widget: SingleChildScrollView(
            padding: EdgeInsetsDirectional.fromSTEB(24.w, 32.h, 24.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PhoneVerificationStrings.enterCodePrompt,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
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
                          errorText: controller.errorMessage.value.isNotEmpty
                              ? controller.errorMessage.value
                              : null,
                          onChanged: (_) {
                            if (controller.errorMessage.value.isNotEmpty) {
                              controller.errorMessage.value = '';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Obx(() {
                  final cooldown = controller.pendingCooldownSeconds.value;
                  final cooldownMsg = controller.pendingCooldownMessage.value;
                  final hasCooldown = cooldown > 0 && cooldownMsg.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasCooldown) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 20.sp,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  cooldownMsg,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: 'Cairo',
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                              Text(
                                cooldown >= 60
                                    ? '${(cooldown ~/ 60).toString().padLeft(2, '0')}:${(cooldown % 60).toString().padLeft(2, '0')}'
                                    : '$cooldown',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: hasCooldown ? null : () => _handleSend(controller),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            PhoneVerificationStrings.sendOtpButton,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _handleSend(PhoneVerificationController controller) {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      controller.errorMessage.value = PhoneVerificationStrings.errorInvalidPhone;
      return;
    }

    final myServices = Get.find<MyServices>();
    final currentPhone = myServices.getStorage.read<String>(StorageKeys.userPhone);
    final hasVerifiedPhone = myServices.getStorage.read<bool>(StorageKeys.phoneVerified) ?? false;

    if (currentPhone != null && currentPhone.isNotEmpty && hasVerifiedPhone) {
      _showReplaceDialog(() {
        controller.sendOtp(phone);
      });
    } else {
      controller.sendOtp(phone);
    }
  }

  void _showReplaceDialog(VoidCallback onConfirm) {
    Get.dialog<bool>(
      AlertDialog(
        title: Text(
          PhoneVerificationStrings.changePhoneAction,
          style: TextStyle(fontSize: 16.sp),
        ),
        content: Text(
          PhoneVerificationStrings.replacePhoneConfirm,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(PhoneVerificationStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
              onConfirm();
            },
            child: Text(PhoneVerificationStrings.confirm),
          ),
        ],
      ),
    );
  }
}
