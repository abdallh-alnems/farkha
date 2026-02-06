/// Formats a number, hiding decimal part when it is zero.
/// e.g. 12.0 → "12", 12.5 → "12.5", 12.50 → "12.5"
String formatDecimal(double value, {int decimals = 1}) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  final s = value.toStringAsFixed(decimals);
  return s.replaceAll(RegExp(r'\.0+$'), '');
}
