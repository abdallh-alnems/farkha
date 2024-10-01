import 'package:flutter/material.dart';
import '../widget/ad_widget.dart';
import '../widget/app_bar/app_bar_home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHome(),
      drawer: Drawer(
        backgroundColor: Colors.red,
        child: Container(
          color: Colors.red,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: double.infinity,
          color: Colors.green,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.arrow_outward),
              Text("55"),
              Text("56"),
              Text("اللحم االابيض"),
            ],
          ),
        ),
      ),
              bottomNavigationBar: const AdmobHome(),

    );
  }
}
