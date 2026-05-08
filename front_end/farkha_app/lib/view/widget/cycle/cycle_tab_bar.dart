import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/colors.dart';

class CycleTabBar extends StatelessWidget {
  final TabController controller;
  final bool isDark;

  const CycleTabBar({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor
              : AppColors.lightOutlineColor,
        ),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: isDark
              ? AppColors.darkPrimaryColor
              : AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        dividerColor: Colors.transparent,
        labelColor: isDark ? AppColors.darkBackGroundColor : Colors.white,
        unselectedLabelColor:
            isDark ? Colors.grey[400] : Colors.grey[600],
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        padding: EdgeInsets.all(4.w),
        labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
        tabs: const [
          _TabItem(icon: Icons.dashboard_outlined, label: 'عام'),
          _TabItem(icon: Icons.speed_outlined, label: 'الأداء'),
          _TabItem(icon: Icons.account_balance_wallet_outlined, label: 'المالية'),
          _TabItem(icon: Icons.agriculture_outlined, label: 'المزرعة'),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TabItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 40.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
