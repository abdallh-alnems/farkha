import 'package:farkha_app/core/constant/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GeneralItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Function() onTap;
  const GeneralItem({
    super.key,
    required this.title,
    required this.icon,
    this.color = AppColor.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13).r,
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
                    style: Theme.of(context).textTheme.titleMedium,

          textDirection: TextDirection.rtl,
        ),
        leading: Icon(
          icon,
          size: 21.sp,
          color: color,
        ),
      ),
    );
  }
}
