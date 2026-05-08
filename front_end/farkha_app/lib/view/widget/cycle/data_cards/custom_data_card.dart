import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../logic/controller/cycle_custom_data_controller.dart';
import 'custom_data_dialogs.dart';
import 'custom_data_entry_list.dart';

class CustomDataCard extends StatefulWidget {
  final CustomDataItem item;
  final int itemIndex;
  final bool isViewer;

  const CustomDataCard({
    super.key,
    required this.item,
    required this.itemIndex,
    required this.isViewer,
  });

  @override
  State<CustomDataCard> createState() => _CustomDataCardState();
}

class _CustomDataCardState extends State<CustomDataCard> {
  late final CycleCustomDataController customDataCtrl;
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final isHistoryExpanded = false.obs;

  @override
  void initState() {
    super.initState();
    customDataCtrl = Get.find<CycleCustomDataController>();
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Obx(() {
      final entries = widget.item.entries;
      final lastEntry = entries.isNotEmpty ? entries.last : null;
      final sortedEntries = List<CustomDataEntry>.from(entries)
        ..sort((a, b) => b.date.compareTo(a.date));

      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.12 : 0.08),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.w, 14.w, 10.w),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      widget.item.icon,
                      color: colorScheme.primary,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.label,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            height: 1.2,
                          ),
                        ),
                        if (entries.isNotEmpty)
                          Text(
                            '${entries.length} ${entries.length == 1 ? 'إدخال' : 'إدخالات'}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (entries.length > 1)
                    buildHistoryToggle(isHistoryExpanded, colorScheme),
                  if (!widget.isViewer) ...[
                    SizedBox(width: 6.w),
                    buildActionIcon(
                      icon: Icons.close_rounded,
                      color: colorScheme.error,
                      onTap: () => showDeleteCustomDataConfirmDialog(
                        context,
                        widget.itemIndex,
                        widget.item.label,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: isHistoryExpanded.value && sortedEntries.isNotEmpty
                  ? CustomDataEntryList(
                      sortedEntries: sortedEntries,
                      item: widget.item,
                      itemIndex: widget.itemIndex,
                      isViewer: widget.isViewer,
                    )
                  : lastEntry != null
                      ? CustomDataSingleEntry(
                          entry: lastEntry,
                          item: widget.item,
                          itemIndex: widget.itemIndex,
                          isViewer: widget.isViewer,
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 20.h),
                          child: Center(
                            child: Text(
                              'لا توجد بيانات بعد',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                        ),
            ),
            if (!widget.isViewer)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 12.w),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'أدخل بيانات جديدة',
                          hintStyle: TextStyle(
                            fontSize: 12.sp,
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.35),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5)
                              : colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colorScheme.onSurface,
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            customDataCtrl.addEntry(widget.itemIndex, value);
                            textController.clear();
                            focusNode.unfocus();
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Material(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10.r),
                      child: InkWell(
                        onTap: () {
                          final value = textController.text;
                          if (value.isNotEmpty) {
                            customDataCtrl.addEntry(widget.itemIndex, value);
                            textController.clear();
                            focusNode.unfocus();
                          } else {
                            focusNode.requestFocus();
                          }
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.add_rounded,
                            color: colorScheme.onPrimary,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
      );
    });
  }
}
