import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/constant/routes/get_page.dart';
import 'core/constant/theme/theme.dart';
import 'core/services/analytics_service.dart';
import 'core/services/dark_light_service.dart';
import 'core/services/initialization.dart';
import 'logic/bindings/app_binding.dart';

void main() async {
  await initialServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget { 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final analytics = Get.find<AnalyticsService>().analytics;
        final themeService = Get.find<DarkLightService>();
        return Obx(() {
          // Read observable first so GetX always has a valid subscription (avoids "improper use" crash)
          final themeMode = themeService.themeMode.value;
          return GetMaterialApp(
            locale: const Locale('ar'),
            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.upToDown,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialBinding: AppBindings(),
            getPages: pages,
            theme: AppTheme().lightThemes(),
            darkTheme: AppTheme().darkThemes(),
            themeMode: themeMode,
            // home: Cycle(),
          );
        });
      },
    );
  }
}
