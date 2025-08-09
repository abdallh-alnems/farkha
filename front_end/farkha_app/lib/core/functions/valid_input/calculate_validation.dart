import 'package:flutter/material.dart';
import '../../shared/bottom_message.dart';

class CalculateValidation {
  /// دالة عامة للتحقق من صحة المدخلات وعرض رسالة خطأ
  static bool validateInputs(
    BuildContext context,
    List<bool> conditions,
    String errorMessage,
  ) {
    for (bool condition in conditions) {
      if (condition) {
        BottomMessage.show(context, errorMessage);
        return false;
      }
    }
    return true;
  }

  /// دالة للتحقق من الأرقام الصحيحة
  static bool validateNumbers(
    BuildContext context,
    List<num> values,
    String errorMessage,
  ) {
    List<bool> conditions = values.map((value) => value <= 0).toList();
    return validateInputs(context, conditions, errorMessage);
  }

  /// دالة للتحقق من الأرقام الصحيحة مع شروط إضافية
  static bool validateNumbersWithConditions(
    BuildContext context,
    List<num> values,
    List<bool> additionalConditions,
    String errorMessage,
  ) {
    List<bool> conditions = [
      ...values.map((value) => value <= 0),
      ...additionalConditions,
    ];
    return validateInputs(context, conditions, errorMessage);
  }
}
