import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/constant/routes/get_page.dart';
import 'core/constant/theme/theme.dart';
import 'core/services/initialization.dart';
import 'logic/bindings/my_binding.dart';
import 'view/screen/prices/main_types.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          // تحسين Hot Reload
          showPerformanceOverlay: false,
          showSemanticsDebugger: false,
          // تحسين إدارة الحالة
          defaultTransition: Transition.fade,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], 
          initialBinding: MyBindings(),
          getPages: pages,
          theme: AppTheme().lightThemes(),
          //  defaultTransition: Transition.downToUp,
        );
      },
    );
  }
}
