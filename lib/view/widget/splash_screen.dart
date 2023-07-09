import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:farkha_app/view/screen/home/home_screen.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splashIconSize: 90,
      pageTransitionType: PageTransitionType.leftToRight,
      splashTransition: SplashTransition.decoratedBoxTransition,
      splash: Image.asset(
        'assets/images/logo.png',
      ),
      nextScreen: const HomeScreen(),
    );
  }
}
