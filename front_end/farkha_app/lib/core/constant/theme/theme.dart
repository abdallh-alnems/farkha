import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'color.dart';

ThemeData appThemes = ThemeData(
  fontFamily: "Cairo",
  scaffoldBackgroundColor: AppColor.appBackGroundColor,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColor.primaryColor,
    titleTextStyle: TextStyle(fontSize: 25.sp, color: Colors.white),
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: AppColor.primaryColor,
      statusBarIconBrightness: Brightness.light,
    ),
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 23.sp, color: AppColor.primaryColor),
    headlineMedium: TextStyle(fontSize: 15.sp, color: Colors.red,fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 13.sp),
    bodyMedium: TextStyle(fontSize: 15.sp),
  ),
);
