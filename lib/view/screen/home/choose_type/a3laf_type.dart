import 'package:farkha_app/view/widget/home/continar_type/continartype.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class A3lafType extends StatelessWidget {
  const A3lafType({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 40,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ContinarType(
            type: 'بط مسكوفي',
          ),
          ContinarType(
            type: 'بط مولار',
          ),
          ContinarType(
            type: 'بط فرنساوي',
          ),
          
        ],
      ),
    ));
  }
}
