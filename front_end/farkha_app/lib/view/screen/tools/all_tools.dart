import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/constant/tools_list.dart';
import '../../../logic/controller/tools_controller/favorite_tools_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';

class AllTools extends StatefulWidget {
  const AllTools({super.key});

  @override
  State<AllTools> createState() => _AllToolsState();
}

class _AllToolsState extends State<AllTools> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  String _normalizeText(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه');
  }

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteToolsController>();
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن أداة...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: iconColor.withValues(alpha: 0.7),
                    ),
                  ),
                  style: TextStyle(color: iconColor, fontSize: 16),
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query.trim();
                    });
                  },
                )
                : Text('الادوات', style: TextStyle(color: iconColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: iconColor, size: 26),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            iconSize: 26,
            color: iconColor,
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const AdNativeWidget(),
              const SizedBox(height: 19),

              Obx(() {
                // دمج جميع الأدوات
                final allTools = [...toolsBeforeAd, ...toolsAfterAd];

                // فلترة الأدوات بناءً على البحث
                final filteredTools =
                    _searchQuery.isEmpty
                        ? allTools
                        : allTools.where((tool) {
                          final normalizedToolText = _normalizeText(tool.text);
                          final normalizedSearchQuery = _normalizeText(
                            _searchQuery,
                          );
                          return normalizedToolText.contains(
                            normalizedSearchQuery,
                          );
                        }).toList();

                // ترتيب الأدوات: المفضلة أولاً حسب ترتيب الإضافة
                filteredTools.sort((a, b) {
                  final aIsFavorite = favoriteController.isFavorite(a.text);
                  final bIsFavorite = favoriteController.isFavorite(b.text);

                  // إذا كانت إحداهما مفضلة والأخرى لا
                  if (aIsFavorite && !bIsFavorite) return -1;
                  if (!aIsFavorite && bIsFavorite) return 1;

                  // إذا كانتا مفضلتين، ترتيب حسب ترتيب الإضافة
                  if (aIsFavorite && bIsFavorite) {
                    final aIndex = favoriteController.getFavoriteIndex(a.text);
                    final bIndex = favoriteController.getFavoriteIndex(b.text);
                    return aIndex.compareTo(bIndex);
                  }

                  // إذا لم تكونا مفضلتين، الحفاظ على الترتيب الأصلي
                  return 0;
                });

                // عرض رسالة في حال عدم وجود نتائج
                if (filteredTools.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'لا توجد أدوات تطابق البحث',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 19,
                    childAspectRatio: 1.33,
                  ),
                  itemCount: filteredTools.length,
                  itemBuilder: (context, index) {
                    final item = filteredTools[index];
                    return _buildToolCard(context, item);
                  },
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildToolCard(BuildContext context, ToolsItem item) {
    final favoriteController = Get.find<FavoriteToolsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color cardColor =
        isDark ? AppColors.darkSurfaceElevatedColor : Colors.white;
    final Color borderColor = (isDark
            ? AppColors.darkOutlineColor
            : AppColors.lightOutlineColor)
        .withValues(alpha: isDark ? 0.5 : 0.6);
    final Color textColor = colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor, width: isDark ? 1 : 1.5),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(13),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.image != null)
                    SvgPicture.asset(item.image!, width: 47, height: 47)
                  else if (item.isTextIcon == true)
                    Text(
                      item.text,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  const SizedBox(height: 19),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      item.text,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Obx(() {
              final isFavorite = favoriteController.isFavorite(item.text);
              return InkWell(
                onTap: () {
                  final wasNotFavorite = !isFavorite;
                  favoriteController.toggleFavorite(item.text);

                  // إذا تم إضافة الأداة للمفضلة، التمرير للأعلى
                  if (wasNotFavorite) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _scrollToTop();
                    });
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber : Colors.grey,
                    size: 22,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  static List<ToolsItem> get toolsBeforeAd => allToolsList
      .where((e) => e.showBeforeAd)
      .map(
        (e) => ToolsItem(
          text: e.text,
          image: e.image,
          onTap: () => Get.toNamed<void>(e.route),
          relatedArticleIds: e.relatedArticleIds,
        ),
      )
      .toList();

  static List<ToolsItem> get toolsAfterAd => allToolsList
      .where((e) => !e.showBeforeAd)
      .map(
        (e) => ToolsItem(
          text: e.text,
          image: e.image,
          onTap: () => Get.toNamed<void>(e.route),
          relatedArticleIds: e.relatedArticleIds,
        ),
      )
      .toList();
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
