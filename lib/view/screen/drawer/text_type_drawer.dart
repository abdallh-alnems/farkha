import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextTypeDrawer extends StatelessWidget {
  String text;
   TextTypeDrawer({super.key,required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextUtils(
          text: 'اسعار الفراخ',
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
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
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(right: 10, left: 10),
        child: Text(text),
      ),
    );
  }
}
