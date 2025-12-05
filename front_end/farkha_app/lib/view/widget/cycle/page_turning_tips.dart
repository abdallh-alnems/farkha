import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageTurningTips extends StatelessWidget {
  final Animation<Offset> arrowAnimation;

  const PageTurningTips({super.key, required this.arrowAnimation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // السهم المتحرك
            SlideTransition(
              position: arrowAnimation,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 24.sp,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // النص التوضيحي
            Text(
              'اسحب للتنقل بين الدورات',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
