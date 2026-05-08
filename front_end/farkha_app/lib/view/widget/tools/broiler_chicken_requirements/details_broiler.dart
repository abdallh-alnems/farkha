import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/theme/theme.dart';
import '../../../../logic/controller/tools_controller/broiler_controller.dart';

class DetailsBroiler extends StatelessWidget {
  const DetailsBroiler({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.isRegistered<BroilerController>()
        ? Get.find<BroilerController>()
        : null;

    if (controller == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor.withValues(alpha: 0.4)
              : colorScheme.primary.withValues(alpha: 0.12),
        ),
        boxShadow: isDark ? null : [AppElevation.shadow(opacity: 0.06)],
      ),
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
      child: Row(
        children: [
          Expanded(
            child: _buildDetailItem(
              context: context,
              label: 'العدد',
              value: controller.chickensCountController.text,
              icon: Icons.numbers_outlined,
            ),
          ),
          _buildDivider(context),
          Expanded(
            child: _buildDetailItem(
              context: context,
              label: 'العمر',
              value: controller.selectedChickenAge.value?.toString() ?? '-',
              icon: Icons.calendar_today_outlined,
              suffix: 'يوم',
            ),
          ),
          _buildDivider(context),
          Expanded(
            child: Obx(() => _buildDetailItem(
                  context: context,
                  label: 'الموقع',
                  value: controller.weatherLocationShort,
                  icon: Icons.location_on_outlined,
                  isLocation: true,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    String? suffix,
    bool isLocation = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: AppDimens.borderSm,
          ),
          child: Icon(icon, color: colorScheme.primary, size: 18.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 4.h),
        if (isLocation)
          SizedBox(
            width: 90.w,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
              children: [
                TextSpan(text: value),
                if (suffix != null)
                  TextSpan(
                    text: ' $suffix',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w400,
                        ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 48.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            colorScheme.outline.withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
