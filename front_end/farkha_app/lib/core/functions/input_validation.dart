class InputValidation {
  /// Converts Arabic (٠١٢٣٤٥٦٧٨٩) and Persian/Indic (۰۱۲۳۴۵۶۷۸۹) digits to English (0123456789).
  static String normalizeToEnglishDigits(String input) {
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    const englishDigits = '0123456789';
    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(arabicDigits[i], englishDigits[i]);
      result = result.replaceAll(persianDigits[i], englishDigits[i]);
    }
    return result;
  }

  static String? validateAndFormatNumber(
    String? input, {
    bool allowZero = false,
  }) {
    const double minValue = 0;
    const double maxValue = 99999999;
    const int maxDecimalPlaces = 2;

    if (input == null || input.trim().isEmpty) {
      return 'يرجى إدخال قيمة';
    }

    final trimmedInput = input.trim();
    final normalizedInput = normalizeToEnglishDigits(trimmedInput);

    String cleanInput = normalizedInput.replaceAll(RegExp(r'[^\d.]'), '');

    final dots = cleanInput.split('.');
    if (dots.length > 2) {
      cleanInput = '${dots[0]}.${dots[1]}';
    }

    final number = double.tryParse(cleanInput);
    if (number == null) {
      return 'يرجى إدخال رقم صحيح';
    }

    if (number < minValue) {
      return 'لا يمكن استخدام أرقام سالبة';
    }

    if (!allowZero && number == minValue) {
      return 'القيمة يجب أن تكون أكبر من صفر';
    }

    if (number > maxValue) {
      return 'القيمة كبيرة جداً';
    }

    final decimalIndex = cleanInput.indexOf('.');
    if (decimalIndex != -1 &&
        cleanInput.length - decimalIndex - 1 > maxDecimalPlaces) {
      return 'يرجى إدخال رقم بحد أقصى $maxDecimalPlaces خانات عشرية';
    }

    // Input is valid, return null (no error)
    return null;
  }
}
