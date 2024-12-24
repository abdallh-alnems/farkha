import 'package:flutter/material.dart';
import 'view_main.dart';

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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Main(),
                ),
              ),
              child: const Text("اضافة"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("عرض"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("تحديث"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("مسح"),
            ),
          ],
        ),
      ),
    );
  }
}
