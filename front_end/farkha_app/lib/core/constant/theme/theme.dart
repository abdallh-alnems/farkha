import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'color.dart';

ThemeData appThemes = ThemeData(

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColor.primaryColor,
    titleTextStyle: TextStyle(),
    iconTheme: IconThemeData(
            color: Colors.white, // تغيير لون أيقونة الـ Drawer هنا
          ),
  ),
  textTheme: const TextTheme()
);
