import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/tools_controller/favorite_tools_controller.dart';

class ToolCard extends StatelessWidget {
  final ToolsItem item;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onFavoriteAdded;

  const ToolCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.colorScheme,
    required this.onFavoriteAdded,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteToolsController>();

    final Color cardColor = isDark
        ? AppColors.darkSurfaceElevatedColor
        : AppColors.lightSurfaceColor;
    final Color borderColor = (isDark
            ? AppColors.darkOutlineColor
            : AppColors.lightOutlineColor)
        .withValues(alpha: isDark ? 0.4 : 0.35);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              spreadRadius: 0.5,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: item.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() {
                      final isFavorite =
                          favoriteController.isFavorite(item.text);
                      return FavoriteButton(
                        isFavorite: isFavorite,
                        isDark: isDark,
                        colorScheme: colorScheme,
                        onTap: () {
                          final wasNotFavorite = !isFavorite;
                          favoriteController.toggleFavorite(item.text);
                          if (wasNotFavorite) {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              onFavoriteAdded,
                            );
                          }
                        },
                      );
                    }),
                  ],
                ),
                SizedBox(height: 1.h),
                _buildIcon(),
                SizedBox(height: 6.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    item.text,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (item.image != null) {
      return SvgPicture.asset(
        item.image!,
        width: 32.w,
        height: 32.h,
      );
    }

    if (item.isTextIcon == true) {
      return Text(
        item.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 20.sp,
          color: colorScheme.primary,
          height: 1,
        ),
        maxLines: 1,
      );
    }

    return SizedBox(width: 32.w, height: 32.h);
  }
}

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(4.r),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            key: ValueKey(isFavorite),
            color: isFavorite
                ? AppColors.secondaryColor
                : colorScheme.onSurface.withValues(alpha: 0.25),
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}

class ToolsItem {
  final String text;
  final String? image;
  final bool? isTextIcon;
  final VoidCallback onTap;
  final List<int>? relatedArticleIds;

  const ToolsItem({
    required this.text,
    this.image,
    this.isTextIcon,
    required this.onTap,
    this.relatedArticleIds,
  });
}
