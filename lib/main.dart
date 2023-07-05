import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:farkha_app/logic/binding/my_binding.dart';
import 'package:farkha_app/routes/routes.dart';
import 'package:farkha_app/view/screen/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: MyBindings(),
      home: AnimatedSplashScreen(
        splashIconSize: 90,
        pageTransitionType: PageTransitionType.leftToRight,
        splashTransition: SplashTransition.decoratedBoxTransition,
        
        splash: Image.asset(
          'assets/images/logo.png',
        ),
        nextScreen: HomeScreen(),
      ),
      getPages: AppRoutes.routes,
    );
  }
}
