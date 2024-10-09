import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/constant/theme/color.dart';

class Trt extends StatelessWidget {
  const Trt({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, right: 13, top: 9).r,
      child: Container(
        width: double.infinity,
        height: 105,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: AppColor.primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                Text(
                  "العمر",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 8), // إضافة مسافة بين النص والخط
                Container(
                  width: 23.w, // عرض الخط
                  height: 1.5.h, // سماكة الخط
                  color: Colors.black, // لون الخط
                ),
                Text(
                  "0",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "العمر",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 8), // إضافة مسافة بين النص والخط
                Container(
                  width: 23.w, // عرض الخط
                  height: 1.5.h, // سماكة الخط
                  color: Colors.black, // لون الخط
                ),
                Text(
                  "0",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "العمر",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 8), // إضافة مسافة بين النص والخط
                Container(
                  width: 23.w, // عرض الخط
                  height: 1.5.h, // سماكة الخط
                  color: Colors.black, // لون الخط
                ),
                Text(
                  "0",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
