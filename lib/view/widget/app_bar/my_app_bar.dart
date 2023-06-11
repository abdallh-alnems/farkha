import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  final String text;
  const MyAppBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: TextUtils(
        text: text,
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.cyan,
          size: 40,
        ),
        onPressed: () {
          Get.back();
        },
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
