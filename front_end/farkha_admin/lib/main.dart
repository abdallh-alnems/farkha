import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'logic/binding/my_binding.dart';
import 'routes/get_page.dart';


void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return   GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialBinding: MyBindings(),
            getPages: pages,
           
          );
  }
}
