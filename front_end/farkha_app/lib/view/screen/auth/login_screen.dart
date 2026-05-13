import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/images.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/auth/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  CurvedAnimation _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutQuint),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerHighest,
              isDark
                  ? const Color(0xFF201C16)
                  : AppColors.lightPageBackgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80.h,
              right: -60.w,
              child: Container(
                width: 280.w,
                height: 280.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentColor.withValues(alpha: isDark ? 0.07 : 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60.h,
              left: -40.w,
              child: Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryColor.withValues(alpha: isDark ? 0.05 : 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: IconButton(
                        onPressed: () => Get.back<void>(),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.onSurface
                              .withValues(alpha: 0.04),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusMd),
                          ),
                        ),
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.onSurface.withValues(alpha: 0.45),
                          size: 22.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _staggered(
                      0.0,
                      0.35,
                      _buildLogoSection(theme, isDark),
                    ),
                    const Spacer(),
                    _staggered(
                      0.1,
                      0.5,
                      _buildLoginCard(theme, colorScheme, isDark),
                    ),
                    const Spacer(),
                    _staggered(
                      0.25,
                      0.6,
                      _buildBottomSection(colorScheme),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _staggered(double begin, double end, Widget child) {
    final animation = _interval(begin, end);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildLogoSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                blurRadius: 48,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: AppColors.accentColor.withValues(alpha: 0.12),
                blurRadius: 64,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Image.asset(
            AppImages.logo,
            width: 110.w,
            height: 110.w,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 20.h),
        Text('فرخة', style: theme.textTheme.displayLarge),
        SizedBox(height: 4.h),
        Text(
          'دليلك الذكي لتربية الدواجن',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.darkSecondaryColor : const Color(0xFF8A8274),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightCardBackgroundColor,
        boxShadow: [
          AppElevation.shadow(
            color: colorScheme.onSurface,
            opacity: isDark ? 0.15 : 0.05,
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            'أهلاً بك',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'سجّل دخولك للوصول لجميع أدواتك',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 28.h),
          _buildGoogleButton(theme, colorScheme, isDark),
          if (Platform.isIOS) ...[
            SizedBox(height: 12.h),
            _buildAppleButton(theme, colorScheme, isDark),
          ],
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.25),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Icon(
                  Icons.shield_outlined,
                  size: 14.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.22),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'تسجيل دخول آمن ومحمي',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final controller = Get.find<LoginController>();
    return Obx(
      () => Material(
        color: isDark ? AppColors.darkSurfaceColor : const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: InkWell(
          onTap:
              controller.isLoading.value ? null : controller.onGoogleSignIn,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Container(
            width: double.infinity,
            height: 54.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isGoogleLoading.value)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                    ),
                  )
                else ...[
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4285F4),
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'المتابعة بحساب Google',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppleButton(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final controller = Get.find<LoginController>();
    return Obx(
      () => Material(
        color: isDark ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: InkWell(
          onTap: controller.isLoading.value ? null : controller.onAppleSignIn,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Container(
            width: double.infinity,
            height: 54.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isAppleLoading.value)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  )
                else ...[
                  Icon(
                    Icons.apple,
                    color: isDark ? Colors.black : Colors.white,
                    size: 22.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'المتابعة بحساب Apple',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeaturePill(
          Icons.build_circle_rounded,
          'كل الأدوات',
          colorScheme,
        ),
        _buildFeaturePill(
          Icons.cloud_sync_rounded,
          'حفظ البيانات',
          colorScheme,
        ),
        _buildFeaturePill(Icons.forum_rounded, 'تواصل', colorScheme),
      ],
    );
  }

  Widget _buildFeaturePill(
    IconData icon,
    String label,
    ColorScheme colorScheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primary.withValues(alpha: 0.08),
          ),
          child: Icon(icon, size: 18.sp, color: colorScheme.primary),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
