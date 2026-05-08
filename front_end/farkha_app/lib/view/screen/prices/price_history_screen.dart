import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/price_controller/price_history_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/prices/price_history_chart.dart';

class PriceHistoryScreen extends StatelessWidget {
  const PriceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final int typeId = (args?['type_id'] as num?)?.toInt() ?? 0;
    final String typeName = (args?['type_name'] as String?) ?? 'سجل الأسعار';

    if (typeId <= 0) {
      return const Scaffold(
        appBar: CustomAppBar(text: 'سجل الأسعار'),
        body: Center(child: Text('معرف النوع غير صالح')),
      );
    }

    Get.delete<PriceHistoryController>();
    Get.put(PriceHistoryController(typeId: typeId, typeName: typeName));

    return Scaffold(
      appBar: CustomAppBar(text: 'سجل أسعار $typeName'),
      body: GetBuilder<PriceHistoryController>(
        builder: (controller) {
          return HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: _PriceHistoryBody(controller: controller),
          );
        },
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}

class _PriceHistoryBody extends StatelessWidget {
  const _PriceHistoryBody({required this.controller});

  final PriceHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final list = controller.filteredList;

    if (list.isEmpty && !controller.isFiltering) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48.sp,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'لا توجد سجلات',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _DateFilterBar(controller: controller),
        Expanded(
          child: list.isEmpty && controller.isFiltering
              ? _buildNoResults(context)
              : _buildList(context, list),
        ),
      ],
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list_off_rounded,
            size: 40.sp,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'لا توجد نتائج في هذه الفترة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> list) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            !controller.isFiltering &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 100) {
          controller.loadMore();
        }
        return false;
      },
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.sm,
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: const AdNativeWidget(),
          ),
          ...List.generate(list.length, (i) {
            return PriceHistoryRow(
              item: list[i],
              priceDiff: _getHigherPriceDifference(list, i),
              showBoth: _isValidPrice((list[i]['lower'] ?? '').toString()),
            );
          }),
          if (controller.hasMore)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: controller.isLoadingMore
                    ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }

  bool _isValidPrice(String val) =>
      val.isNotEmpty && val != '-' && val != 'null';

  double? _getHigherPriceDifference(List<Map<String, dynamic>> list, int index) {
    final current =
        double.tryParse((list[index]['higher'] ?? '').toString()) ?? 0.0;

    if (list[index].containsKey('override_date')) {
      final overrideItem = list[index];
      final actualDate = (overrideItem['date'] ?? '').toString().split(' ').first;
      final sourceIndex = controller.historyList.indexWhere(
        (h) => (h['date'] ?? '').toString().startsWith(actualDate),
      );
      if (sourceIndex >= 0 && sourceIndex + 1 < controller.historyList.length) {
        final previous =
            double.tryParse((controller.historyList[sourceIndex + 1]['higher'] ?? '').toString()) ?? 0.0;
        if (previous == 0) return null;
        return current - previous;
      }
      return null;
    }

    if (index + 1 >= list.length) return null;
    final previous =
        double.tryParse((list[index + 1]['higher'] ?? '').toString()) ?? 0.0;
    if (previous == 0) return null;
    return current - previous;
  }
}

class _DateFilterBar extends StatelessWidget {
  const _DateFilterBar({required this.controller});

  final PriceHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showFilterSheet(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: AppDimens.borderSm,
                  border: Border.all(
                    color: controller.isFiltering
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      size: 18.sp,
                      color: controller.isFiltering
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        controller.isFiltering
                            ? _filterLabel()
                            : 'بحث بالتاريخ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: controller.isFiltering
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: controller.isFiltering
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (controller.isFiltering) ...[
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () => controller.clearFilter(),
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 16.sp,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _filterLabel() {
    final start = controller.filterStartDate;
    final end = controller.filterEndDate;
    if (start != null && end != null) {
      final same = start.year == end.year &&
          start.month == end.month &&
          start.day == end.day;
      if (same) return _shortDate(start);
      return '${_shortDate(start)} — ${_shortDate(end)}';
    }
    if (start != null) return _shortDate(start);
    return '';
  }

  String _shortDate(DateTime d) => '${d.day}/${d.month}';

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
      ),
      builder: (_) => PriceHistoryFilterSheet(
        controller: controller,
        parentContext: context,
      ),
    );
  }
}
