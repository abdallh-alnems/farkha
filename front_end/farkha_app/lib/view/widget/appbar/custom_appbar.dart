import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/favorite_tools_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;

  /// Tool name for favorite toggle. Must match the text in [AllTools.toolsBeforeAd]
  /// and [AllTools.toolsAfterAd]. When provided, a star icon is shown to add/remove
  /// the tool from favorites.
  final String? favoriteToolName;

  const CustomAppBar({
    super.key,
    required this.text,
    this.favoriteToolName,
  });

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(color: onSurface),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(right: 7),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: onSurface, size: 27),
          onPressed: () => Get.back<void>(),
          splashRadius: 24,
        ),
      ),
      actions: favoriteToolName != null
          ? [
              Obx(() {
                final favoriteController =
                    Get.find<FavoriteToolsController>();
                final isFavorite =
                    favoriteController.isFavorite(favoriteToolName!);
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber : onSurface,
                    size: 26,
                  ),
                  onPressed: () =>
                      favoriteController.toggleFavorite(favoriteToolName!),
                  splashRadius: 24,
                );
              }),
            ]
          : null,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: onSurface,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
