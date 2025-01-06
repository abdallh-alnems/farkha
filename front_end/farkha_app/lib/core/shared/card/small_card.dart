import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/theme/color.dart';

class SmallCard extends StatelessWidget {
  final String image;
  final String text;
 final void Function() onTap;

  const SmallCard({super.key, required this.image, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              scale: 2.5,
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
