import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/theme.dart';

class CycleCardStageBadge extends StatelessWidget {
  final String stage;
  final int stageIndex;
  final ColorScheme colorScheme;

  const CycleCardStageBadge({
    super.key,
    required this.stage,
    required this.stageIndex,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = colorScheme.brightness == Brightness.dark;
    Color bgColor;
    Color fgColor;
    IconData icon;

    switch (stageIndex) {
      case 0:
        bgColor = colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.12);
        fgColor = colorScheme.primary;
        icon = Icons.thermostat_outlined;
        break;
      case 1:
        bgColor = colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.12);
        fgColor = colorScheme.primary;
        icon = Icons.restaurant_outlined;
        break;
      case 2:
        bgColor = AppColors.accentColor.withValues(alpha: isDark ? 0.2 : 0.12);
        fgColor = isDark ? AppColors.accentLight : AppColors.accentColor;
        icon = Icons.point_of_sale_outlined;
        break;
      default:
        bgColor = colorScheme.surfaceContainerHighest;
        fgColor = colorScheme.onSurface;
        icon = Icons.circle;
    }

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(6.w, 2.h, 6.w, 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: fgColor),
          SizedBox(width: 3.w),
          Text(
            stage,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w700,
              color: fgColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class CycleCardRoleBadge extends StatelessWidget {
  final bool isAdmin;
  final ColorScheme colorScheme;

  const CycleCardRoleBadge({
    super.key,
    required this.isAdmin,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(5.w, 1.h, 5.w, 1.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.manage_accounts_rounded : Icons.remove_red_eye_rounded,
            size: 10.sp,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 2.w),
          Text(
            isAdmin ? 'مشرف' : 'متابع',
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CycleCardLockedState extends StatelessWidget {
  final ColorScheme colorScheme;

  const CycleCardLockedState({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 17.w),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: GestureDetector(
        onTap: () => Get.toNamed<void>(AppRoute.login),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 20.sp, color: colorScheme.primary),
            SizedBox(width: 8.w),
            Text(
              'يجب تسجيل الدخول لمتابعة الدورات',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CycleCardEmptyState extends StatelessWidget {
  final ColorScheme colorScheme;

  const CycleCardEmptyState({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 17.w),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed<void>(AppRoute.addCycle),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 20.sp, color: colorScheme.primary),
                  SizedBox(width: 8.w),
                  Text(
                    'اضف دورة جديدة',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1.w,
            height: 24.h,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          IconButton(
            icon: Icon(Icons.history, color: colorScheme.primary, size: 20.sp),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            onPressed: () => Get.toNamed<void>(AppRoute.history),
          ),
        ],
      ),
    );
  }
}
