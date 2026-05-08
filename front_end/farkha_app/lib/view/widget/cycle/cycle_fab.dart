import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/colors.dart';

class CycleFab extends StatefulWidget {
  final bool isDark;

  const CycleFab({super.key, required this.isDark});

  @override
  State<CycleFab> createState() => _CycleFabState();
}

class _CycleFabState extends State<CycleFab> with SingleTickerProviderStateMixin {
  late final AnimationController _fabController;
  late final Animation<double> _fabAnimation;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _fabAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabAnimation.value,
              alignment: Alignment.bottomRight,
              child: Opacity(
                opacity: _fabAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildFabOption(
                      heroTag: 'sales_fab',
                      label: 'المبيعات',
                      icon: Icons.receipt_long_outlined,
                      isDark: isDark,
                      onTap: () {
                        _toggleFab();
                        Get.toNamed<void>(AppRoute.cycleSales);
                      },
                    ),
                    SizedBox(height: 10.h),
                    _buildFabOption(
                      heroTag: 'expenses_fab',
                      label: 'المصروفات',
                      icon: Icons.account_balance_wallet_outlined,
                      isDark: isDark,
                      onTap: () {
                        _toggleFab();
                        Get.toNamed<void>(AppRoute.cycleExpenses);
                      },
                    ),
                    SizedBox(height: 10.h),
                    _buildFabOption(
                      heroTag: 'data_fab',
                      label: 'البيانات',
                      icon: Icons.insert_chart_outlined,
                      isDark: isDark,
                      onTap: () {
                        _toggleFab();
                        Get.toNamed<void>(AppRoute.cycleData);
                      },
                    ),
                    SizedBox(height: 10.h),
                    _buildFabOption(
                      heroTag: 'notes_fab',
                      label: 'ملاحظات',
                      icon: Icons.note_add_outlined,
                      isDark: isDark,
                      onTap: () {
                        _toggleFab();
                        Get.toNamed<void>(AppRoute.cycleNotes);
                      },
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            );
          },
        ),
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggleFab,
          backgroundColor: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
          child: AnimatedRotation(
            turns: _isFabExpanded ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isFabExpanded ? Icons.close : Icons.add,
              color: isDark ? Colors.black87 : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required String heroTag,
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceElevatedColor
              : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: isDark
                ? Colors.grey[700]!
                : Colors.black.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16.sp,
                color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
