import 'package:farkha_app/core/constant/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppBarSetting extends StatelessWidget {
  const AppBarSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 9).r,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                "الاعدادات",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 23).r,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: ClipOval(
                      child: Container(
                        width: 33,
                        height: 33,
                        color: AppColor.primaryColor,
                        child: Icon(
                          Icons.arrow_right_alt,
                          color: Colors.white,
                          size: 23.sp,
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
