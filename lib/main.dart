import 'package:farkha/view/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'logic/bindings/initial_bindings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBindings(),
      home: Home(),
    );
  }
}
