import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/price_change.dart';
import '../../../logic/controller/price_controller/price_history_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';

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

    Get.put(PriceHistoryController(typeId: typeId, typeName: typeName));

    return Scaffold(
      appBar: CustomAppBar(text: 'سجل أسعار $typeName'),
      body: GetBuilder<PriceHistoryController>(
        builder: (controller) {
          return HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: _PriceHistoryList(controller: controller),
          );
        },
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}

class _PriceHistoryList extends StatelessWidget {
  const _PriceHistoryList({required this.controller});

  final PriceHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyList = controller.historyList;

    if (historyList.isEmpty) {
      return Center(
        child: Text(
          'لا توجد سجلات',
          style: TextStyle(
            fontSize: 16.sp,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 100) {
          controller.loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
        itemCount:
            1 + historyList.length + (controller.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12).r,
              child: const AdNativeWidget(),
            );
          }
          final listIndex = index - 1;
          if (listIndex >= historyList.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: controller.isLoadingMore
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }

          final item = historyList[listIndex];
          final date = item['date'] as String? ?? '';
          final higher = item['higher'] as String? ?? '-';
          final lower = item['lower'] as String? ?? '-';
          final showBoth = lower.isNotEmpty && lower != '-' && lower != 'null';

          // فرق السعر بين هذا السطر والسطر السابق (الأقدم زمنياً)
          final double? higherPriceDiff = _getHigherPriceDifference(
            historyList,
            listIndex,
          );

          return Card(
            margin: EdgeInsets.only(bottom: 8.h),
            color: isDark
                ? AppColors.darkSurfaceElevatedColor
                : AppColors.lightSurfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(
                color: isDark
                    ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
                    : AppColors.lightOutlineColor.withValues(alpha: 0.6),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  if (showBoth)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'أقل',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: (isDark ? Colors.white : Colors.black87)
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            lower,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showBoth ? 'أعلى' : 'السعر',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: (isDark ? Colors.white : Colors.black87)
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          higher,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'التغيير',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: (isDark ? Colors.white : Colors.black87)
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        higherPriceDiff != null && higherPriceDiff != 0
                            ? PriceChangeWidget(
                                priceDifference: higherPriceDiff,
                              )
                            : Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: (isDark ? Colors.white : Colors.black87)
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    final parts = raw.split(' ');
    final datePart = parts.isNotEmpty ? parts[0] : raw;
    final segments = datePart.split('-');
    if (segments.length >= 3) {
      return '${segments[2]}/${segments[1]}/${segments[0]}';
    }
    return raw;
  }

  /// فرق السعر الأعلى بين هذا السطر والسطر التالي (الأقدم زمنياً في القائمة)
  double? _getHigherPriceDifference(
    List<Map<String, dynamic>> list,
    int index,
  ) {
    if (index + 1 >= list.length) return null;
    final current = list[index];
    final previous = list[index + 1];
    final currentHigher =
        double.tryParse((current['higher'] ?? '').toString()) ?? 0.0;
    final previousHigher =
        double.tryParse((previous['higher'] ?? '').toString()) ?? 0.0;
    if (previousHigher == 0) return null;
    return currentHigher - previousHigher;
  }
}
