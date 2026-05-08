import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'dart:async';

import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../widget/cycle/history/history_filter_bar.dart';
import '../../widget/cycle/history/history_cycle_item.dart';

class CycleHistoryScreen extends StatefulWidget {
  const CycleHistoryScreen({super.key});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen>
    with TickerProviderStateMixin {
  late final CycleController cycleCtrl;
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialLoading = true;
  late final AnimationController _revealController;
  late final Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();
    cycleCtrl =
        Get.isRegistered<CycleController>()
            ? Get.find<CycleController>()
            : Get.put(CycleController());
    if (cycleCtrl.searchQuery.value.isNotEmpty) {
      _searchController.text = cycleCtrl.searchQuery.value;
    }
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );
    unawaited(_loadHistory());
  }

  Future<void> _loadHistory() async {
    await cycleCtrl.fetchHistory(isRefresh: true);
    if (mounted) {
      setState(() => _isInitialLoading = false);
      unawaited(_revealController.forward());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سجل الدورات',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            isDark
                ? AppColors.darkBackGroundColor
                : AppColors.appBackGroundColor,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 8.w),
            child: IconButton(
              onPressed: () => Get.toNamed<void>(AppRoute.cycleComparison),
              icon: Icon(
                Icons.compare_arrows_rounded,
                size: 22.sp,
                color: colorScheme.primary,
              ),
              tooltip: 'مقارنة الدورات',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimens.borderMd,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          HistoryFilterBar(
            isDark: isDark,
            searchController: _searchController,
            cycleCtrl: cycleCtrl,
          ),
          Obx(() => _buildCountChip(colorScheme)),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              child:
                  _isInitialLoading
                      ? _buildSkeleton(colorScheme, isDark)
                      : RefreshIndicator(
                          key: const ValueKey('content'),
                          onRefresh: _loadHistory,
                          color: AppColors.primaryColor,
                          backgroundColor: colorScheme.surface,
                          displacement: 40.h,
                          child: Obx(() {
                            if (cycleCtrl.historyCycles.isEmpty) {
                              return _buildEmptyState(colorScheme);
                            }
                            return FadeTransition(
                              opacity: _revealAnimation,
                              child: ListView.builder(
                                controller: cycleCtrl.historyScrollController,
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  4.h,
                                  16.w,
                                  24.h,
                                ),
                                itemCount:
                                    cycleCtrl.historyCycles.length +
                                    (cycleCtrl.isLoadingMore.value ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index ==
                                      cycleCtrl.historyCycles.length) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: 18.w,
                                          height: 18.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return HistoryCycleItem(
                                    cycle: cycleCtrl.historyCycles[index],
                                    isDark: isDark,
                                    cycleCtrl: cycleCtrl,
                                  );
                                },
                              ),
                            );
                          }),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(ColorScheme colorScheme) {
    final count = cycleCtrl.historyCycles.length;
    if (count == 0 || _isInitialLoading) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 14.sp,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 5.w),
                Text(
                  '$count دورة',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    final isSearching = cycleCtrl.searchQuery.value.isNotEmpty;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.h),
          child: Column(
            children: [
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  isSearching
                      ? Icons.search_off_rounded
                      : Icons.history_rounded,
                  size: 44.sp,
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                isSearching
                    ? 'لا توجد نتائج تطابق بحثك'
                    : 'لا يوجد سجل دورات سابقة',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isSearching) ...[
                SizedBox(height: 6.h),
                Text(
                  'ستظهر هنا الدورات بعد انتهائها',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.35),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(ColorScheme colorScheme, bool isDark) {
    final bone = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.04);

    Widget boneBox(double w, double h, [BorderRadius? r]) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: bone,
        borderRadius: r ?? BorderRadius.circular(6.r),
      ),
    );

    return ListView.builder(
      key: const ValueKey('skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      itemCount: 3,
      itemBuilder: (context, _) {
        return Container(
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppDimens.borderXl,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.05),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                offset: const Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    boneBox(130.w, 14.h),
                    Row(
                      children: [
                        boneBox(48.w, 24.h, BorderRadius.circular(12.r)),
                        SizedBox(width: 6.w),
                        boneBox(36.w, 24.h, BorderRadius.circular(12.r)),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: bone,
                        borderRadius: AppDimens.borderLg,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: bone,
                              borderRadius: AppDimens.borderLg,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: bone,
                              borderRadius: AppDimens.borderLg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: bone,
                              borderRadius: AppDimens.borderLg,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: bone,
                              borderRadius: AppDimens.borderLg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black12
                      : const Color(0xFFF8FAFC).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppDimens.radiusXl),
                  ),
                ),
                child: Divider(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    4,
                    (_) => Column(
                      children: [
                        boneBox(40.w, 10.h),
                        SizedBox(height: 6.h),
                        boneBox(28.w, 8.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
