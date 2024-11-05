import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'routes/get_page.dart';


void main() async {
  runApp(const MyApp());
    await dotenv.load(fileName: ".env");

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return   GetMaterialApp(
            debugShowCheckedModeBanner: false,
            getPages: pages,
           
          );
  }
}
