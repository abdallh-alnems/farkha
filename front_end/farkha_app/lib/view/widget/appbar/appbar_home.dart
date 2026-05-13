import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/images.dart';

class AppBarHome extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      leading: Builder(
        builder: (innerContext) => IconButton(
          icon: Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.menu, color: colorScheme.primary, size: 20.sp),
          ),
          onPressed: () => Scaffold.of(innerContext).openDrawer(),
        ),
      ),
      title: Text(
        'فرخة',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: EdgeInsets.all(7.r),
          child: Image.asset(AppImages.logo, fit: BoxFit.contain, height: 28.h),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
