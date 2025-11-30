import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/package/rating_app.dart';
import '../../../core/services/open_gmail.dart';
import 'drawer_item.dart';

class DrawerMenuItems extends StatelessWidget {
  const DrawerMenuItems({super.key});

  void _handleShareApp(BuildContext context) {
    Navigator.pop(context);
    Share.share(
      'حمل تطبيق فرخة \n https://play.google.com/store/apps/details?id=ni.nims.frkha',
    );
  }

  void _handleOpenGmail(BuildContext context) {
    Navigator.pop(context);
    openGmail();
  }

  void _handleSuggestion(BuildContext context) {
    Navigator.pop(context);
    Get.toNamed(AppRoute.suggestion);
  }

  void _handleRateApp(BuildContext context) {
    Navigator.pop(context);
    final rateController = Get.find<RateMyAppController>();
    rateController.launchStore();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DrawerItem(
          onTap: () => _handleShareApp(context),
          title: 'مشاركة التطبيق',
          icon: Icons.share,
          color: const Color(0xFF2196F3), // أزرق فاتح
        ),
        DrawerItem(
          onTap: () => _handleOpenGmail(context),
          title: 'البريد الإلكتروني',
          icon: Icons.mail,
          color: const Color(0xFFE91E63), // وردي/أحمر فاتح
        ),
        DrawerItem(
          onTap: () => _handleSuggestion(context),
          title: 'اقتراح',
          icon: Icons.lightbulb,
          color: const Color(0xFFFF9800), // برتقالي
        ),
        DrawerItem(
          onTap: () => _handleRateApp(context),
          title: 'قيمنا ',
          icon: Icons.star,
          color: const Color(0xFFFFC107), // ذهبي/أصفر
        ),
      ],
    );
  }
}


