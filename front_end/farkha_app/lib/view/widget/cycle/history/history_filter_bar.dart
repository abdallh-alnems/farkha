import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constant/theme/colors.dart';
import '../../../../logic/controller/cycle_controller.dart';

class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    super.key,
    required this.isDark,
    required this.searchController,
    required this.cycleCtrl,
  });

  final bool isDark;
  final TextEditingController searchController;
  final CycleController cycleCtrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSearchBar(colorScheme)),
            GestureDetector(
              onTap: () async {
                final initialDateRange =
                    cycleCtrl.filterDateFrom.value.isNotEmpty &&
                            cycleCtrl.filterDateTo.value.isNotEmpty
                        ? DateTimeRange(
                          start: DateTime.parse(cycleCtrl.filterDateFrom.value),
                          end: DateTime.parse(cycleCtrl.filterDateTo.value),
                        )
                        : null;

                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDateRange: initialDateRange,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme:
                            isDark
                                ? const ColorScheme.dark(
                                  primary: AppColors.primaryColor,
                                )
                                : const ColorScheme.light(
                                  primary: AppColors.primaryColor,
                                ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  final DateFormat formatter = DateFormat('yyyy-MM-dd');
                  cycleCtrl.setDateFilter(
                    formatter.format(picked.start),
                    formatter.format(picked.end),
                  );
                }
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(16.w, 16.h, 0, 0),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color:
                      cycleCtrl.filterDateFrom.value.isNotEmpty
                           ? AppColors.primaryColor.withValues(alpha: 0.2)
                          : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      cycleCtrl.filterDateFrom.value.isNotEmpty
                          ? Border.all(color: AppColors.primaryColor)
                          : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.date_range,
                  color:
                      cycleCtrl.filterDateFrom.value.isNotEmpty
                          ? AppColors.primaryColor
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          if (cycleCtrl.filterDateFrom.value.isNotEmpty &&
              cycleCtrl.filterDateTo.value.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                       color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                         color: AppColors.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'من ${cycleCtrl.filterDateFrom.value} إلى ${cycleCtrl.filterDateTo.value}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => cycleCtrl.clearDateFilter(),
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          cycleCtrl.searchHistory(value);
        },
        decoration: InputDecoration(
          hintText: 'ابحث بإسم الدورة...',
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          suffixIcon:
              searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      searchController.clear();
                      cycleCtrl.searchHistory('');
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }
}
