import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:farkha_app/core/constant/theme/theme.dart';

class TestHarness {
  static Future<void> pump(
    WidgetTester tester,
    Widget widget, {
    bool darkMode = false,
    Locale locale = const Locale('ar'),
    List<Bindings> bindings = const [],
  }) async {
    for (final binding in bindings) {
      binding.dependencies();
    }

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme().lightThemes(),
          darkTheme: AppTheme().darkThemes(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: widget,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  static void setUpGetx() {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '.';
      }
      return null;
    });
    Get.testMode = true;
  }

  static bool _storageInitialized = false;

  static Future<void> ensureGetStorage() async {
    if (!_storageInitialized) {
      await GetStorage.init();
      _storageInitialized = true;
    }
  }

  static Future<GetStorage> getStorage() async {
    await ensureGetStorage();
    return GetStorage();
  }

  static void tearDownGetx() {
    Get.reset();
  }
}
