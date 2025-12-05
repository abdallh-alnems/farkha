import 'package:flutter/material.dart';

import '../../../core/constant/theme/images.dart';

class AppBarHome extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color onBackground = theme.colorScheme.onSurface;
    return AppBar(
      title: Text(
        "فرخة",
        style: theme.textTheme.headlineLarge?.copyWith(color: onBackground),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(7),
          child: Image.asset(AppImages.logo, fit: BoxFit.contain),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
