import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/constant/routes/get_page.dart';
import 'core/constant/theme/theme.dart';
import 'core/services/dark_light_service.dart';
import 'core/services/initialization.dart';
import 'core/services/update_service.dart';
import 'logic/bindings/app_binding.dart';

void main() async {
  await initialServices();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recheckUpdate();
    }
  }

  Future<void> _recheckUpdate() async {
    try {
      if (Get.isRegistered<UpdateService>()) {
        await Get.find<UpdateService>().check();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final themeService = Get.find<DarkLightService>();
        return Obx(() {
          final themeMode = themeService.themeMode.value;
          return GetMaterialApp(
            locale: const Locale('ar'),
            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.upToDown,
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
          );
        });
      },
    );
  }
}
