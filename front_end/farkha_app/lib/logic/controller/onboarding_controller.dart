import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/initialization.dart';
import '../../data/data_source/static/onboarding_static.dart';

abstract class OnBoardingController extends GetxController {
  void next();
  void onPageChanged(int index);
  void skip();
}

class OnBoardingControllerImp extends OnBoardingController {
  late PageController pageController;

  final RxInt currentPage = 0.obs;

  MyServices myServices = Get.find();

  @override
  void next() {
    currentPage.value++;

    if (currentPage.value > onBoardingList.length - 1) {
      myServices.getStorage.write("step", "1");
      Get.offAllNamed("/");
    } else {
      pageController.animateToPage(
        currentPage.value,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
      update();
    }
  }

  @override
  void skip() {
    myServices.getStorage.write("step", "1");
    update();
    Get.offAllNamed("/");
  }

  @override
  void onPageChanged(int index) {
    currentPage.value = index;
    update();
  }

  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
  }
}
