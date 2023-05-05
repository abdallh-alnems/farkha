import 'package:farkha_app/logic/controller/onboarding_controller.dart';
import 'package:farkha_app/data/static.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSliderOnboarding extends GetView<OnboardingControllerImp> {
  const CustomSliderOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: (val) {
        controller.onPageChange(val);
      },
      itemCount: onboardingList.length,
      itemBuilder: (context, i) => Column(
        children: [
          Text(
            onboardingList[i].title!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(
            height: 80,
          ),
          Image.asset(
            onboardingList[i].image!,
            width: 250,
            height: 230,
            fit: BoxFit.fill,
          ),
          const SizedBox(
            height: 80,
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              onboardingList[i].body!,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 2),
            ),
          ),
          const SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }
}
