import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
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

  Widget _buildImage(String imagePath) {
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        width: 28.w,
        height: 28.h,
      );
    } else {
      return Image.asset(imagePath, scale: 3.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteToolsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color cardColor =
        isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor;
    final Color borderColor = (isDark
            ? AppColors.darkOutlineColor
            : AppColors.lightOutlineColor)
        .withValues(alpha: isDark ? 0.5 : 0.3);
    final Color textColor = colorScheme.onSurface;
    final Color accentColor = colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        width: 75.w,
        height: 68.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10).r,
          color: cardColor,
          border: Border.all(color: borderColor, width: 0.8),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                spreadRadius: 0.5,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10).r,
                child:
              image != null
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 5.h),
                      _buildImage(image!),
                      SizedBox(height: 3.h),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: Center(
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                                color: textColor.withValues(alpha: 0.8),
                                height: 1.2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.h),
                      // Stylish text in place of image
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: accentColor,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: accentColor.withValues(alpha: 0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      // Normal text below
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: Center(
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: textColor.withValues(alpha: 0.8),
                                height: 1.2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
              ),
            ),
            if (showFavorite)
              Positioned(
                top: 2,
                right: 2,
                child: Obx(
                  () {
                    final isFavorite = favoriteController.isFavorite(text);
                    return InkWell(
                      onTap: () => favoriteController.toggleFavorite(text),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber : Colors.grey,
                          size: 14,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
