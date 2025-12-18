import 'package:flutter/material.dart';

import 'drawer_about_app.dart';
import 'drawer_account_settings.dart';
import 'drawer_header.dart';
import 'drawer_privacy_security.dart';
import 'drawer_support_contact.dart';

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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DrawerAccountSettings(),
                    DrawerPrivacySecurity(),
                    DrawerSupportContact(),
                    DrawerAboutApp(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
