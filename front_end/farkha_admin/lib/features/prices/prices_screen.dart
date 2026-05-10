import 'package:flutter/material.dart';
import 'main_types_screen.dart';

class PricesScreen extends StatelessWidget {
  const PricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الأسعار"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainTypesScreen()),
              ),
              child: const Text("إضافة"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainTypesScreen(isEditMode: true)),
              ),
              child: const Text("تعديل"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainTypesScreen(isDeleteMode: true)),
              ),
              child: const Text("حذف"),
            ),
          ],
        ),
      ),
    );
  }
}
