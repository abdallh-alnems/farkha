// ignore_for_file: prefer_const_constructors

import 'package:farkha_app/routes/routes.dart';
import 'package:farkha_app/view/screen/home_screen.dart';
import 'package:farkha_app/data/static.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class OnboardingController extends GetxController {
  next();
  onPageChange(int index);
}

class OnboardingControllerImp extends OnboardingController {
  late PageController pageController;
  int currentPage = 0;
  @override
  next() {
    currentPage++;
    if (currentPage > onboardingList.length - 1) {
      Get.offNamed(Routes.HomeScreen);
    } else {
      pageController.animateToPage(currentPage,
          duration: const Duration(milliseconds: 900), curve: Curves.easeInOut);
    }
  }

  @override
  onPageChange(int index) {
    currentPage = index;
    update();
  }

  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
  }
}
