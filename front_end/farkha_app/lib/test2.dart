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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle,
                color: Colors.white,
                size: 25,
              ),
              Text(
                "اضف دورة",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          )),
    );
  }
}
