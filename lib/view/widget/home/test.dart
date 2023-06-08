import 'package:farkha_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Get.toNamed(Routes.HomeScreen);
        },
        child: Text('Home'));
  }
}
