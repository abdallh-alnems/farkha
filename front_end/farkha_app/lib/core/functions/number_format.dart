const _arabicDigits = <String, String>{
  '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
  '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9', '،': '',
};

String normalizeDigits(String input) {
  return input.replaceAllMapped(
    RegExp(r'[٠-٩،]'),
    (m) => _arabicDigits[m[0]] ?? m[0]!,
  );
}

double? tryParseNum(String input) {
  return double.tryParse(normalizeDigits(input));
}

int? tryParseInt(String input) {
  return int.tryParse(normalizeDigits(input));
}

/// Formats a number, hiding decimal part when it is zero.
/// e.g. 12.0 → "12", 12.5 → "12.5", 12.50 → "12.5"
String formatDecimal(double value, {int decimals = 1}) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  final s = value.toStringAsFixed(decimals);
  return s.replaceAll(RegExp(r'\.0+$'), '');
}
