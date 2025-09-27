import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/initialization.dart';
import '../../data/data_source/static/onboarding_static.dart';

abstract class OnBoardingController extends GetxController {
  next();
  onPageChanged(int index);
  skip();
}

class OnBoardingControllerImp extends OnBoardingController {
  late PageController pageController;

  int currentPage = 0;

  MyServices myServices = Get.find();

  @override
  next() {
    currentPage++;

    if (currentPage > onBoardingList.length - 1) {
      myServices.getStorage.write("step", "1");
      Get.offAllNamed("/");
    } else {
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
      // تحديث الـ dot_controller
      update();
    }
  }

  @override
  skip() {
    myServices.getStorage.write("step", "1");
    // تحديث الـ dot_controller قبل الانتقال
    update();
    Get.offAllNamed("/");
  }

  @override
  onPageChanged(int index) {
    currentPage = index;
    update();
  }

  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
  }
}
