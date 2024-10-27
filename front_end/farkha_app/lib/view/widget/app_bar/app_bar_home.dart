import 'package:farkha_app/core/constant/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constant/theme/imgae_asset.dart';

class AppBarHome extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "فرخة",
        style: TextStyle(fontSize: 25.sp, color: Colors.white),
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
            Get.toNamed(AppRoute.settings);
          },
          child: Image.asset(
            AppImageAsset.setting,
            scale: 2.8.sp,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
