import 'package:flutter/material.dart';

import 'drawer_footer.dart';
import 'drawer_header.dart';
import 'drawer_menu_items.dart';
import 'drawer_theme_toggle.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Drawer(
      width: screenWidth * 0.7,
      child: const SafeArea(
        child: Column(
          children: [
            DrawerHeaderWidget(),
            Expanded(child: SingleChildScrollView(child: DrawerMenuItems())),
            DrawerThemeToggle(),
            DrawerFooter(),
          ],
        ),
      ),
    );
  }
}
