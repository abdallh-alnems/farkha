import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'color.dart';

class AppTheme {
  ThemeData lightThemes() => ThemeData(
    fontFamily: "Cairo",
    scaffoldBackgroundColor: AppColor.appBackGroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColor.appBackGroundColor,
      surfaceTintColor: AppColor.appBackGroundColor,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 25.sp, color: Colors.white),
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 21.sp, color: AppColor.primaryColor),
      headlineMedium: TextStyle(
        fontSize: 15.sp,
        color: Colors.red,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(fontSize: 13.sp),
      titleMedium: TextStyle(fontSize: 15.sp, color: AppColor.primaryColor),
      bodyMedium: TextStyle(fontSize: 15.sp),
      displaySmall: TextStyle(
        fontSize: 13.sp,
        color: AppColor.primaryColor,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: TextStyle(
        fontSize: 15.sp,
        color: AppColor.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
