import 'package:farkha_app/utils/theme.dart';
import 'package:farkha_app/view/widget/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  final String text;
  const MyAppBar({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Text(DateFormat('y/MM/dd').format(DateTime.now())),
          ),
        )
      ],
      centerTitle: true,
      title: TextUtils(
        text: text,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      backgroundColor: scaColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 25,
        ),
        onPressed: () {
          Get.back();
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
