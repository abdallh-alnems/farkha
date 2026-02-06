import 'package:flutter/material.dart';
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

    return Obx(() {
      // Explicit read so GetX always has a subscription (avoids "improper use" crash)
      final _ = favoriteController.favoriteToolsOrder.length;
      // دمج جميع الأدوات مع ترتيب المفضلة أولاً
      final allToolsSorted = <ToolEntry>[...allToolsList];

      allToolsSorted.sort((a, b) {
        final aIsFavorite = favoriteController.isFavorite(a.text);
        final bIsFavorite = favoriteController.isFavorite(b.text);

        // المفضلة أولاً
        if (aIsFavorite && !bIsFavorite) return -1;
        if (!aIsFavorite && bIsFavorite) return 1;

        // إذا كانتا مفضلتين، ترتيب حسب ترتيب الإضافة
        if (aIsFavorite && bIsFavorite) {
          final aIndex = favoriteController.getFavoriteIndex(a.text);
          final bIndex = favoriteController.getFavoriteIndex(b.text);
          return aIndex.compareTo(bIndex);
        }

        // الباقي يبقى بترتيبه الأصلي
        return 0;
      });

      return Column(
        key: toolsSectionKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ادوات مساعدة',
                  key: toolsTitleKey,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed<void>(AppRoute.allTools),
                  child: Row(
                    key: viewAllKey,
                    children: const [
                      Text(
                        'عرض الكل',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            key: toolsScrollViewKey,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:
                  allToolsSorted.map((entry) {
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
