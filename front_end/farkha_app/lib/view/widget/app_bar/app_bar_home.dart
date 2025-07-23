import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/image_asset.dart';

class AppBarHome extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "فرخة",
      ),
      actions: [
        Text(
          '(${DateFormat('EEEE', 'ar').format(DateTime.now())})',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(
          width: 1.w,
        ),
        Text(
          DateFormat('MM/dd').format(DateTime.now()),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(
          width: 9.w,
        ),
      ],
      leading: Padding(
        padding: const EdgeInsets.only(left: 5).r,
        child: GestureDetector(
          onTap: () {
            Get.toNamed(AppRoute.general);
          },
          child: Image.asset(
            ImageAsset.setting,
            scale: 2.8,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
