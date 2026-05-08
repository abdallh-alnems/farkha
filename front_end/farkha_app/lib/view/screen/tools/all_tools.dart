import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/constant/tools_list.dart';
import '../../../logic/controller/tools_controller/favorite_tools_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/tools/tool_card.dart';

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
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final show = _scrollController.offset > 300;
    if (show != _showScrollToTop) {
      setState(() => _showScrollToTop = show);
    }
  }

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
        curve: Curves.easeOutQuart,
      );
    }
  }

  String _normalizeText(String text) {
    var normalized = text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .trim();
    if (normalized.startsWith('ال')) {
      normalized = normalized.substring(2);
    }
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteToolsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField(colorScheme)
            : Text(
                'الادوات',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24.sp),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            iconSize: 24.sp,
            color: colorScheme.onSurface,
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
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 8.h)),
              const SliverToBoxAdapter(child: AdNativeWidget()),
              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              Obx(() {
                final allTools = [...toolsBeforeAd, ...toolsAfterAd];

                final filteredTools = _searchQuery.isEmpty
                    ? allTools
                    : allTools.where((tool) {
                        final normalizedToolText =
                            _normalizeText(tool.text);
                        final normalizedSearchQuery =
                            _normalizeText(_searchQuery);
                        final searchWords = normalizedSearchQuery
                            .split(' ')
                            .where((w) => w.isNotEmpty);
                        return searchWords.every(
                            (word) => normalizedToolText.contains(word));
                      }).toList();

                filteredTools.sort((a, b) {
                  final aIsFavorite =
                      favoriteController.isFavorite(a.text);
                  final bIsFavorite =
                      favoriteController.isFavorite(b.text);

                  if (aIsFavorite && !bIsFavorite) return -1;
                  if (!aIsFavorite && bIsFavorite) return 1;

                  if (aIsFavorite && bIsFavorite) {
                    final aIndex =
                        favoriteController.getFavoriteIndex(a.text);
                    final bIndex =
                        favoriteController.getFavoriteIndex(b.text);
                    return aIndex.compareTo(bIndex);
                  }

                  return 0;
                });

                if (filteredTools.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmptyState(colorScheme),
                  );
                }

                final favorites = filteredTools
                    .where((t) => favoriteController.isFavorite(t.text))
                    .toList();
                final others = filteredTools
                    .where((t) => !favoriteController.isFavorite(t.text))
                    .toList();

                return SliverMainAxisGroup(
                  slivers: [
                    if (favorites.isNotEmpty) ...[
                      _buildSectionHeader(
                        'المفضلة',
                        Icons.star_rounded,
                        AppColors.secondaryColor,
                        colorScheme,
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: 12.h),
                      ),
                      _buildToolsGrid(favorites, isDark, colorScheme),
                      SliverToBoxAdapter(
                        child: SizedBox(height: 24.h),
                      ),
                    ],
                    if (others.isNotEmpty) ...[
                      _buildSectionHeader(
                        'جميع الادوات',
                        Icons.grid_view_rounded,
                        colorScheme.primary,
                        colorScheme,
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: 12.h),
                      ),
                      _buildToolsGrid(others, isDark, colorScheme),
                    ],
                  ],
                );
              }),
              SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          ),
       ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              elevation: AppElevation.sm,
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: colorScheme.primary,
                size: 20.sp,
              ),
            )
          : null,
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'ابحث عن أداة...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
          fontSize: 15.sp,
        ),
      ),
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 15.sp,
      ),
      onChanged: (query) {
        setState(() {
          _searchQuery = query.trim();
        });
      },
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color accentColor,
    ColorScheme colorScheme,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: Row(
          children: [
            Container(
              width: 3.5.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(icon, size: 18.sp, color: accentColor),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد أدوات تطابق البحث',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGrid(
    List<ToolsItem> tools,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.25,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = tools[index];
            return ToolCard(
              item: item,
              isDark: isDark,
              colorScheme: colorScheme,
              onFavoriteAdded: _scrollToTop,
            );
          },
          childCount: tools.length,
        ),
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


