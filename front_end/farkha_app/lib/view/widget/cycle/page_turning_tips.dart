import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageTurningTips extends StatelessWidget {
  final Animation<Offset> arrowAnimation;

  const PageTurningTips({super.key, required this.arrowAnimation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SlideTransition(
            position: arrowAnimation,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 55.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 13.h),
          Text(
            'اسحب للتنقل بين الدورات',
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
