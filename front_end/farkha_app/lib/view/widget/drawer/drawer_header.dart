import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/images.dart';
import '../../../core/services/initialization.dart';

class DrawerHeaderWidget extends StatefulWidget {
  const DrawerHeaderWidget({super.key});

  @override
  State<DrawerHeaderWidget> createState() => _DrawerHeaderWidgetState();
}

class _DrawerHeaderWidgetState extends State<DrawerHeaderWidget> {
  @override
  void initState() {
    super.initState();
    // Refresh when drawer is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myServices = Get.find<MyServices>();
    final isLoggedIn =
        myServices.getStorage.read<bool>('is_logged_in') ?? false;
    final userName = myServices.getStorage.read<String>('user_name');

    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppImages.logo,
            height: 80,
            width: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          if (isLoggedIn && userName != null)
            Text(
              userName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          else
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(AppRoute.login);
              },
              child: Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
