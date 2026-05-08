import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/tools_list.dart';
import '../../../logic/controller/tools_controller/favorite_tools_controller.dart';
import '../tools/tools_card.dart';

class ToolsSection extends StatelessWidget {
  final GlobalKey? toolsSectionKey;
  final GlobalKey? toolsTitleKey;
  final GlobalKey? viewAllKey;
  final GlobalKey? toolsScrollViewKey;

  const ToolsSection({
    super.key,
    this.toolsSectionKey,
    this.toolsTitleKey,
    this.viewAllKey,
    this.toolsScrollViewKey,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteToolsController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final _ = favoriteController.favoriteToolsOrder.length;
      final allToolsSorted = <ToolEntry>[...allToolsList];

      allToolsSorted.sort((a, b) {
        final aIsFavorite = favoriteController.isFavorite(a.text);
        final bIsFavorite = favoriteController.isFavorite(b.text);

        if (aIsFavorite && !bIsFavorite) return -1;
        if (!aIsFavorite && bIsFavorite) return 1;

        if (aIsFavorite && bIsFavorite) {
          final aIndex = favoriteController.getFavoriteIndex(a.text);
          final bIndex = favoriteController.getFavoriteIndex(b.text);
          return aIndex.compareTo(bIndex);
        }

        return 0;
      });

      return Column(
        key: toolsSectionKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 18.h,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'ادوات مساعدة',
                      key: toolsTitleKey,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Get.toNamed<void>(AppRoute.allTools),
                  child: Container(
                    key: viewAllKey,
                    padding: EdgeInsetsDirectional.fromSTEB(10.w, 5.h, 10.w, 5.h),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'عرض الكل',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 10.sp,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          SingleChildScrollView(
            key: toolsScrollViewKey,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsetsDirectional.only(start: 12.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: allToolsSorted.map((entry) {
                return ToolsCard(
                  onTap: () => Get.toNamed<void>(entry.route),
                  image: entry.image,
                  text: entry.text,
                  showFavorite: true,
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }
}
