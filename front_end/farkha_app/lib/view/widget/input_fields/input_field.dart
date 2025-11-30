import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/functions/input_validation.dart';

class InputField extends StatelessWidget {
  final String label;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final String? hintText;
  final String? suffixText;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    required this.label,
    this.onChanged,
    this.controller,
    this.hintText,
    this.suffixText,
    this.suffixIcon,
    this.suffixIconConstraints,
    this.keyboardType = TextInputType.number,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: InputValidation.validateAndFormatNumber,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13.sp),
        hintText: hintText,
        suffixText: suffixIcon == null ? suffixText : null,
        suffixIcon: suffixIcon,
        suffixIconConstraints: suffixIconConstraints,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
