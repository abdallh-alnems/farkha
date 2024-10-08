import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constant/theme/color.dart';

class CardPrice extends StatelessWidget {
  final String titleCard;
  const CardPrice({super.key, required this.titleCard});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, right: 13, top: 9).r,
      child: InkWell(
        child: Container(
          width: double.infinity,
          height: 37.h,
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 19.sp,
              ),
              SizedBox(
                width: 13.w,
              ),
              Text(
                titleCard,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
