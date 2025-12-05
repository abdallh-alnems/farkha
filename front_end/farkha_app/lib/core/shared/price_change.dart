import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PriceChangeWidget extends StatelessWidget {
  final double priceDifference;

  const PriceChangeWidget({super.key, required this.priceDifference});

  @override
  Widget build(BuildContext context) {
    final absValue = priceDifference.abs();

    // عرض التغيير مع إزالة الأصفار غير الضرورية
    final displayValue =
        absValue % 1 == 0
            ? absValue.toInt().toString()
            : absValue.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    final sign = priceDifference > 0 ? '+' : '-';

    return Text(
      "$sign$displayValue",
      style: TextStyle(
        color: _getChangeColor(priceDifference),
        fontWeight: FontWeight.bold,
        fontSize: 13.sp,
      ),
    );
  }

  Color _getChangeColor(double difference) {
    if (difference > 0) return Colors.red;
    return Colors.green;
  }
}
