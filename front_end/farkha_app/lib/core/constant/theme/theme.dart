import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

class AppTheme {
  ThemeData lightThemes() => ThemeData(
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: AppColors.appBackGroundColor,
    colorScheme: _lightColorScheme,
    appBarTheme: _appBarTheme(
      backgroundColor: AppColors.appBackGroundColor,
      overlayBrightness: Brightness.dark,
      titleColor: Colors.white,
    ),
    textTheme: _lightTextTheme,
    elevatedButtonTheme: _elevatedButtonTheme(),
    drawerTheme: const DrawerThemeData(surfaceTintColor: Colors.transparent),
  );

  ThemeData darkThemes() => ThemeData(
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: AppColors.darkBackGroundColor,
    colorScheme: _darkColorScheme,
    appBarTheme: _appBarTheme(
      backgroundColor: AppColors.darkBackGroundColor,
      overlayBrightness: Brightness.light,
      titleColor: AppColors.darkPrimaryColor,
    ),
    textTheme: _darkTextTheme,
    elevatedButtonTheme: _elevatedButtonTheme(),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.darkSurfaceColor,
      surfaceTintColor: Colors.transparent,
    ),
  );

  ColorScheme get _lightColorScheme => ColorScheme.fromSeed(
    seedColor: AppColors.primaryColor,
    brightness: Brightness.light,
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    surface: AppColors.appBackGroundColor,
  );

  ColorScheme get _darkColorScheme => ColorScheme.fromSeed(
    seedColor: AppColors.darkPrimaryColor,
    brightness: Brightness.dark,
    primary: AppColors.darkPrimaryColor,
    secondary: AppColors.darkSecondaryColor,
    surface: AppColors.darkBackGroundColor,
  );

  AppBarTheme _appBarTheme({
    required Color backgroundColor,
    required Brightness overlayBrightness,
    required Color titleColor,
  }) => AppBarTheme(
    backgroundColor: backgroundColor,
    surfaceTintColor: backgroundColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(fontSize: 25.sp, color: titleColor),
    systemOverlayStyle: SystemUiOverlayStyle(
      // Status bar - transparent for edge-to-edge
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: overlayBrightness,
      statusBarBrightness:
          overlayBrightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
      // Navigation bar - transparent for edge-to-edge
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: overlayBrightness,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  TextTheme get _lightTextTheme => TextTheme(
    headlineLarge: TextStyle(fontSize: 21.sp, color: AppColors.primaryColor),
    headlineMedium: TextStyle(
      fontSize: 15.sp,
      color: Colors.red,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(fontSize: 13.sp),
    titleMedium: TextStyle(fontSize: 15.sp, color: AppColors.primaryColor),
    bodyMedium: TextStyle(fontSize: 15.sp),
    displaySmall: TextStyle(
      fontSize: 13.sp,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: TextStyle(
      fontSize: 15.sp,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w600,
    ),
  );

  TextTheme get _darkTextTheme => TextTheme(
    headlineLarge: TextStyle(
      fontSize: 21.sp,
      color: AppColors.darkPrimaryColor,
    ),
    headlineMedium: TextStyle(
      fontSize: 15.sp,
      color: AppColors.darkPrimaryColor,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(fontSize: 13.sp, color: Colors.white70),
    titleMedium: TextStyle(fontSize: 15.sp, color: AppColors.darkPrimaryColor),
    bodyMedium: TextStyle(fontSize: 15.sp, color: Colors.white),
    displaySmall: TextStyle(
      fontSize: 13.sp,
      color: AppColors.darkPrimaryColor,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: TextStyle(
      fontSize: 15.sp,
      color: AppColors.darkPrimaryColor,
      fontWeight: FontWeight.w600,
    ),
  );

  ElevatedButtonThemeData _elevatedButtonTheme() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
    ),
  );
}
