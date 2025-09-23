import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PriceChangeWidget extends StatelessWidget {
  final double priceDifference;

  const PriceChangeWidget({super.key, required this.priceDifference});

  @override
  Widget build(BuildContext context) {
    return Text(
      priceDifference == 0
          ? "0"
          : "${priceDifference.abs().toInt()}${priceDifference > 0 ? '+' : '-'}",
      style: TextStyle(
        color: _getChangeColor(priceDifference),
        fontWeight: FontWeight.bold,
        fontSize: 14.sp,
      ),
    );
  }

  Color _getChangeColor(double difference) {
    if (difference == 0) return Colors.black;
    if (difference > 0) return Colors.red;
    return Colors.green;
  }
}
