class InputValidation {
  static String? validateAndFormatNumber(String? input) {
    const double minValue = 0;
    const double maxValue = 99999999;
    const int maxDecimalPlaces = 2;

    if (input == null || input.trim().isEmpty) {
      return 'يرجى إدخال قيمة';
    }

    final trimmedInput = input.trim();

    String cleanInput = trimmedInput.replaceAll(RegExp(r'[^\d.]-'), '');

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

    if (number == minValue) {
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
