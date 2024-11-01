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
   
  ),
  textTheme: TextTheme(
    headlineMedium: TextStyle(fontSize: 23.sp, color: AppColor.primaryColor),
  ),
);
