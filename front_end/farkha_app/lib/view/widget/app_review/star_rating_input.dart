import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StarRatingInput extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;
  final double size;

  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= value;
        return GestureDetector(
          onTap: () => onChanged(starIndex),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isSelected
                  ? const Color(0xFFFFA726)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
              size: size.sp,
            ),
          ),
        );
      }),
    );
  }
}
