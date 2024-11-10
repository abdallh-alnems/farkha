import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/constant/routes/get_page.dart';
import 'core/constant/theme/theme.dart';
import 'core/services/initialization.dart';
import 'logic/bindings/my_binding.dart';
import 'view/screen/general/suggestion.dart';

void main() async {
  await initialServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialBinding: MyBindings(),
            getPages: pages,
            theme: appThemes,
          //  home: Suggestion(),
          );
        });
  }
}
