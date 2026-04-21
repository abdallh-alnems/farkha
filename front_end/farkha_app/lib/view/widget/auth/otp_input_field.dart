import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OtpInputField extends StatelessWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String> onChanged;

  const OtpInputField({
    super.key,
    this.length = 6,
    required this.onCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PinCodeTextField(
        appContext: context,
        length: length,
        animationType: AnimationType.fade,
        keyboardType: TextInputType.number,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(8.r),
          fieldHeight: 50.h,
          fieldWidth: 44.w,
          activeFillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          inactiveFillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          selectedFillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        cursorColor: Theme.of(context).colorScheme.primary,
        textStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: Theme.of(context).colorScheme.onSurface,
        ),
        backgroundColor: Colors.transparent,
        enableActiveFill: true,
        onCompleted: onCompleted,
        onChanged: onChanged,
      ),
    );
  }
}
