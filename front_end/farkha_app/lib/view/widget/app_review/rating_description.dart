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

  Color _getColor(BuildContext context) {
    switch (rating) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.deepOrange;
      case 3:
        return Colors.amber.shade700;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (rating == 0) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        _getText(),
        key: ValueKey(rating),
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: _getColor(context),
        ),
      ),
    );
  }
}
