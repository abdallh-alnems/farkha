import 'package:farkha_app/logic/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends GetView<OnboardingControllerImp> {
  const CustomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(shape: CircleBorder()),
        onPressed: () {
          controller.next();
        },
        child: Icon(Icons.nat),
      ),
    );
  }
}
