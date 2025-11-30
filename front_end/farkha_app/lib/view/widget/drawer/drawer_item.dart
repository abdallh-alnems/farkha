import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Function() onTap;
  const DrawerItem({
    super.key,
    required this.title,
    required this.icon,
    this.color =  Colors.black,
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
                    style: TextStyle(fontSize: 15.sp,),

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
