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
              child: Text("Add"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("Add"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("Add"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("view"),
            ),
          ],
        ),
      ),
    );
  }
}
