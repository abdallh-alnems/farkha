import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/image_asset.dart';
import 'web_bar_menu.dart';

class WebBar extends StatelessWidget implements PreferredSizeWidget {
  const WebBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        WebBarMenu(
          items: const {
            'مقالات': AppRoute.articlesType,
            'احتياجات فراخ التسمين': AppRoute.broilerChickenRequirements,
          },
          label: 'ادوات المساعدة',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: WebBarMenu(
            items: const {
              'دراسة جدوي': AppRoute.feasibilityStudy,
              'استهلاك العلف': AppRoute.feedConsumption,
              'كثافة الفراخ': AppRoute.chickenDensity,
            },
            label: 'احسب',
          ),
        ),
        Text(
          "الصفحة الرئيسية",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 33).r,
          child: Image.asset(
            ImageAsset.logo,
            scale: 7,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
