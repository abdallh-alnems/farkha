import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../constant/theme/color.dart';

class SmallCard extends StatelessWidget {
  final String image;
  final String text;

  const SmallCard({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Get.snackbar(
                '',
                '',
                titleText: const Text(
                  '',
                  style: TextStyle(fontSize: 0),
                  textAlign: TextAlign.center,
                ),
                messageText: const Text(
                  'قريبا',
                  style: TextStyle(fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              );
      },
      child: Container(
        width: 101.w,
        height: 87.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7).r,
          color: AppColor.secondaryColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              image,
              scale: 2.5.sp,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall,

            )
          ],
        ),
      ),
    );
  }
}
