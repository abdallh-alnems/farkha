import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/constant/storage_keys.dart';

class FavoriteToolsController extends GetxController {
  final GetStorage _storage = Get.find<GetStorage>();
  final RxList<String> favoriteToolsOrder = <String>[].obs;

  static const int maxFavorites = 10;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  void _loadFavorites() {
    final List<dynamic>? favorites = _storage.read(StorageKeys.favoriteToolsOrder);
    if (favorites != null) {
      favoriteToolsOrder.assignAll(favorites.cast<String>());
    }
  }

  void toggleFavorite(String toolName) {
    if (favoriteToolsOrder.contains(toolName)) {
      favoriteToolsOrder.remove(toolName);
      _showSnackbar(
        message: 'تم الإزالة من المفضلة',
        icon: Icons.star_border,
        backgroundColor: Colors.grey.shade700,
      );
    } else {
      if (favoriteToolsOrder.length >= maxFavorites) {
        _showSnackbar(
          message: 'لا يمكن إضافة أكثر من $maxFavorites أدوات مفضلة',
          icon: Icons.warning_amber_rounded,
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 2),
        );
        return;
      }
      favoriteToolsOrder.add(toolName);
      _showSnackbar(
        message: 'تم الإضافة للمفضلة',
        icon: Icons.star,
        backgroundColor: Colors.amber.shade700,
      );
    }
    _saveFavorites();
  }

  bool isFavorite(String toolName) {
    return favoriteToolsOrder.contains(toolName);
  }

  void _saveFavorites() {
    _storage.write(StorageKeys.favoriteToolsOrder, favoriteToolsOrder);
  }

  List<String> getFavoritesList() {
    return favoriteToolsOrder.toList();
  }

  int getFavoriteIndex(String toolName) {
    return favoriteToolsOrder.indexOf(toolName);
  }

  void clearAllFavorites() {
    if (favoriteToolsOrder.isEmpty) {
      _showSnackbar(
        message: 'لا توجد أدوات مفضلة لحذفها',
        icon: Icons.info_outline,
        backgroundColor: Colors.blue.shade700,
      );
      return;
    }

    favoriteToolsOrder.clear();
    _saveFavorites();
    _showSnackbar(
      message: 'تم مسح جميع المفضلات',
      icon: Icons.delete_outline,
      backgroundColor: Colors.red.shade700,
    );
  }

  void reorderFavorites(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = favoriteToolsOrder.removeAt(oldIndex);
    favoriteToolsOrder.insert(newIndex, item);
    _saveFavorites();
  }

  void _showSnackbar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    // استخدام ScaffoldMessenger بدلاً من GetX Snackbar لتجنب مشاكل Overlay
    try {
      final context = Get.context;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: backgroundColor,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    } catch (e) {
      debugPrint('Snackbar error (ignored): $e');
    }
  }
}
