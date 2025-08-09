import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final VoidCallback? onAlertTap;

  const CustomAppBar({super.key, required this.text, this.onAlertTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(color: Colors.black),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 27,
        ),
        onPressed: () => Get.back(),
        splashRadius: 24,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 17),
          child: GestureDetector(
            onTap: onAlertTap,
            child: Icon(Icons.priority_high, color: Colors.black, size: 21),
          ),
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
