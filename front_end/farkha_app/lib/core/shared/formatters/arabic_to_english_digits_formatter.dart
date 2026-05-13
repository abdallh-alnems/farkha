import 'package:flutter/services.dart';

import '../../functions/input_validation.dart';

class ArabicToEnglishDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = InputValidation.normalizeToEnglishDigits(newValue.text);
    if (normalized == newValue.text) return newValue;
    final offset = newValue.selection.baseOffset.clamp(0, normalized.length);
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
