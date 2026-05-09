import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/tools_controller/favorite_tools_controller.dart';

class ToolsCard extends StatelessWidget {
  final String? image;
  final String text;
  final void Function() onTap;
  final bool showFavorite;

  const ToolsCard({
    super.key,
    this.image,
    required this.text,
    required this.onTap,
    this.showFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteToolsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color cardColor = isDark
        ? AppColors.darkSurfaceElevatedColor
        : AppColors.lightSurfaceColor;
    final Color borderColor = (isDark
            ? AppColors.darkOutlineColor
            : AppColors.lightOutlineColor)
        .withValues(alpha: isDark ? 0.4 : 0.25);
    final Color iconBgColor = colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(
        width: 82.w,
        height: 85.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          color: cardColor,
          border: Border.all(color: borderColor, width: 0.8),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                spreadRadius: 0.5,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (image != null)
                        SizedBox(
                          width: 36.w,
                          height: 36.h,
                          child: Center(
                            child: _buildImage(image!),
                          ),
                        )
                      else
                        SizedBox(
                          width: 36.w,
                          height: 36.h,
                          child: Center(
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16.sp,
                                color: colorScheme.primary,
                                height: 1,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      SizedBox(height: 6.h),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (showFavorite)
              Positioned(
                top: 2,
                right: 2,
                child: Obx(() {
                  final isFavorite = favoriteController.isFavorite(text);
                  return InkWell(
                    onTap: () => favoriteController.toggleFavorite(text),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(3.r),
                      child: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? AppColors.secondaryColor : colorScheme.onSurface.withValues(alpha: 0.3),
                        size: 14,
                      ),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        width: 20.w,
        height: 20.h,
      );
    } else {
      return Image.asset(imagePath, scale: 4);
    }
  }
}
