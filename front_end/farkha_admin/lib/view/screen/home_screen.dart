import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/route.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoute.add),
              child: Text("اضافة"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("عرض"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("تحديث"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("مسح"),
            ),
          ],
        ),
      ),
    );
  }
}
