import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AppBarHome extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("فرخة", style: TextStyle(color: Colors.black)),
      actions: [
        Text(
          '(${DateFormat('EEEE', 'ar').format(DateTime.now())})',
          style: const TextStyle(color: Colors.black),
        ),
        SizedBox(width: 1.w),
        Text(
          DateFormat('MM/dd').format(DateTime.now()),
          style: const TextStyle(color: Colors.black),
        ),
        SizedBox(width: 9.w),
      ],
      //  actions: const [
      //   Text(
      //     "فرخة",
      //     style: TextStyle(
      //       color: Colors.black,
      //       fontSize: 25,
      //       fontWeight: FontWeight.w900,
      //     ),
      //   ),
      //   SizedBox(width: 13),
      // ],
      // leading: Padding(
      //   padding: const EdgeInsets.only(left: 5).r,
      //   child: GestureDetector(
      //     onTap: () {
      //       Get.toNamed(AppRoute.general);
      //     },
      //     child: Image.asset(ImageAsset.setting, scale: 2.8),
      //   ),
      // ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
