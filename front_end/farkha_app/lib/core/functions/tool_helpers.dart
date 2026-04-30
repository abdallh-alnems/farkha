import 'package:flutter/material.dart';

import '../constant/theme/colors.dart';

Color getQualityColor(int quality) {
  switch (quality) {
    case 0:
      return Colors.green;
    case 1:
      return Colors.orange;
    case 2:
      return Colors.amber;
    case 3:
      return Colors.red;
    default:
      return AppColors.primaryColor;
  }
}

String getQualityLabel(int quality) {
  switch (quality) {
    case 0:
      return 'ممتاز';
    case 1:
      return 'جيد';
    case 2:
      return 'مقبول';
    case 3:
      return 'يحتاج تحسين';
    default:
      return '';
  }
}

double safeDivide(double numerator, double denominator, {double multiplier = 1.0}) {
  return denominator > 0 ? (numerator / denominator) * multiplier : 0.0;
}
