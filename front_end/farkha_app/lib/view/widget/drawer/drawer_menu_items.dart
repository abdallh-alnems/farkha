import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';


import '../../../core/package/rating_app.dart';
import '../../../core/services/open_gmail.dart';
import '../../../logic/bindings/app_review_binding.dart';
import '../../widget/app_review/app_review_dialog.dart';
import 'drawer_item.dart';

class DrawerMenuItems extends StatelessWidget {
  const DrawerMenuItems({super.key});

  void _handleShareApp(BuildContext context) {
    Navigator.pop(context);
    SharePlus.instance.share(
      ShareParams(
        text:
            'حمل تطبيق فرخة \n https://play.google.com/store/apps/details?id=ni.nims.frkha',
      ),
    );
  }

  void _handleOpenGmail(BuildContext context) {
    Navigator.pop(context);
    openGmail();
  }

  void _handleRateApp(BuildContext context) {
    Navigator.pop(context);
    final rateController = Get.find<RateMyAppController>();
    rateController.launchStore();
  }

  void _handleAppReview(BuildContext context) {
    Navigator.pop(context);
    final binding = AppReviewBinding();
    binding.dependencies();
    showDialog<void>(
      context: context,
      builder: (_) => const AppReviewDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DrawerItem(
          onTap: () => _handleShareApp(context),
          title: 'مشاركة التطبيق',
          icon: Icons.share,
          color: const Color(0xFF2196F3),
        ),
        DrawerItem(
          onTap: () => _handleOpenGmail(context),
          title: 'البريد الإلكتروني',
          icon: Icons.mail,
          color: const Color(0xFFE91E63),
        ),
        DrawerItem(
          onTap: () => _handleRateApp(context),
          title: 'قيمنا ',
          icon: Icons.star,
          color: const Color(0xFFFFC107),
        ),
        DrawerItem(
          onTap: () => _handleAppReview(context),
          title: 'قيّم التطبيق',
          icon: Icons.star_outline,
          color: const Color(0xFFFFC107),
        ),
      ],
    );
  }
}
