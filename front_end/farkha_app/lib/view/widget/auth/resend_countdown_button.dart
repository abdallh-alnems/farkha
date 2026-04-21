import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/phone_verification_strings.dart';
import '../../../logic/controller/auth/phone_verification_controller.dart';

class ResendCountdownButton extends StatelessWidget {
  final VoidCallback onResend;

  const ResendCountdownButton({
    super.key,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhoneVerificationController>();

    return Obx(() {
      final remaining = controller.resendCountdown.value;
      final enabled = controller.isResendEnabled.value;
      final formatted = remaining >= 60
          ? '${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}'
          : '$remaining ${PhoneVerificationStrings.secondsLabel}';

      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: enabled ? onResend : null,
          style: TextButton.styleFrom(
            foregroundColor: enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              enabled
                  ? PhoneVerificationStrings.resendButton
                  : '${PhoneVerificationStrings.resendCountdown} $formatted',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    });
  }
}
