import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/theme/color.dart';

class BigCard extends StatelessWidget {
  final void Function() onTap;
  final String image;
  final String text;
  const BigCard(
      {super.key,
      required this.image,
      required this.text,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 151.w,
        height: 111.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7).r,
          color: AppColor.secondaryColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              image,
              scale: 2.1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9).r,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            )
          ],
        ),
      ),
    );
  }
}
