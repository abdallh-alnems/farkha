import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_pages.dart';
import 'core/api/admin_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const FarkhaAdminApp());
}

class FarkhaAdminApp extends StatelessWidget {
  const FarkhaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'فرخة أدمن',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: const Locale('ar'),
      textDirection: TextDirection.rtl,
      initialRoute: '/',
      getPages: AppPages.pages,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class SplashCheck extends StatelessWidget {
  const SplashCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AdminApi.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }
        if (snapshot.data == true) {
          Future.microtask(() => Get.offAllNamed('/dashboard'));
        } else {
          Future.microtask(() => Get.offAllNamed('/login'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
