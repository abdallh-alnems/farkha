import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/constant/theme/images.dart';
import '../../../logic/controller/auth/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // LoginController is already registered in AppBindings
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
          ),
        ),
        child: Stack(
          children: [
            // Top decorative shape
            Positioned(
              top: -120.h,
              right: -100.w,
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryColor.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom decorative shape
            Positioned(
              bottom: -80.h,
              left: -60.w,
              child: Container(
                width: 220.w,
                height: 220.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.oceanGradientStart.withValues(
                        alpha: isDark ? 0.12 : 0.06,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        style: IconButton.styleFrom(
                          backgroundColor: (isDark
                                  ? Colors.white
                                  : Colors.black)
                              .withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 22.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Logo section
                    _buildLogoSection(isDark),

                    const Spacer(),

                    // Login card
                    _buildLoginCard(isDark),

                    const Spacer(),

                    // Bottom section
                    _buildBottomSection(isDark),

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

  Widget _buildLogoSection(bool isDark) {
    return Column(
      children: [
        // Logo with ray/glow effect
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              // Main glow
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.4),
                blurRadius: 60,
                spreadRadius: 20,
              ),
              // Secondary glow
              BoxShadow(
                color: AppColors.oceanGradientStart.withValues(alpha: 0.3),
                blurRadius: 80,
                spreadRadius: 10,
              ),
              // Inner bright glow
              BoxShadow(
                color: AppColors.oceanGradientEnd.withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Image.asset(
            AppImages.logo,
            width: 120.w,
            height: 120.w,
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(height: 20.h),

        // App name
        Text(
          'فرخة',
          style: TextStyle(
            fontSize: 38.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primaryColor,
            letterSpacing: 2,
          ),
        ),

        SizedBox(height: 6.h),

        // Tagline
        Text(
          'دليلك الذكي لتربية الدواجن',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white54 : Colors.black45,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        color:
            isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                : Colors.white,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Welcome text
          Text(
            'أهلاً وسهلاً 👋',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            'سجّل دخولك للبدء',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),

          SizedBox(height: 28.h),

          // Google button
          _buildGoogleButton(isDark),

          SizedBox(height: 20.h),

          // Divider with text
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 16.sp,
                  color: isDark ? Colors.white30 : Colors.grey.shade400,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Security text
          Text(
            'تسجيل دخول آمن ومحمي',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(bool isDark) {
    final controller = Get.find<LoginController>();
    return Obx(
      () => InkWell(
        onTap: controller.isLoading.value ? null : controller.onGoogleSignIn,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.isLoading.value)
                SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: isDark ? Colors.white70 : AppColors.primaryColor,
                  ),
                )
              else ...[
                // Google colored logo
                SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEA4335),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4285F4),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFBBC05),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF34A853),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'المتابعة بحساب Google',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(bool isDark) {
    return Column(
      children: [
        // Features row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureIcon(Icons.build_circle_rounded, 'كل الأدوات', isDark),
            _buildFeatureIcon(Icons.cloud_sync_rounded, 'حفظ البيانات', isDark),
            _buildFeatureIcon(Icons.forum_rounded, 'تواصل', isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDark
                    ? AppColors.darkPrimaryColor
                    : AppColors.primaryColor)
                .withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
