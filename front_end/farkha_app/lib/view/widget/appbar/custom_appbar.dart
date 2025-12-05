import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;

  const CustomAppBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(color: onSurface),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(right: 7),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: onSurface, size: 27),
          onPressed: () => Get.back(),
          splashRadius: 24,
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: onSurface,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
