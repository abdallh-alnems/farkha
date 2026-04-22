import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingDescription extends StatelessWidget {
  final int rating;

  const RatingDescription({super.key, required this.rating});

  String _getText() {
    switch (rating) {
      case 1:
        return 'سيء جداً';
      case 2:
        return 'سيء';
      case 3:
        return 'متوسط';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (rating == 0) return const SizedBox.shrink();
    return Text(
      _getText(),
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
