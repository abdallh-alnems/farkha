import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/functions/number_format.dart';
import '../../../../core/shared/formatters/arabic_to_english_digits_formatter.dart';
import '../../../../data/model/cycle/weight_entry.dart';
import '../../../../logic/controller/cycle_controller.dart';
import 'average_weight_history.dart';
import 'average_weight_dialogs.dart';

class AverageWeightCard extends StatefulWidget {
  const AverageWeightCard({super.key});

  @override
  State<AverageWeightCard> createState() => _AverageWeightCardState();
}

class _AverageWeightCardState extends State<AverageWeightCard> {
  late final CycleController cycleCtrl;
  late final TextEditingController _controller;
  final _isHistoryExpanded = false.obs;

  bool get _isViewer =>
      cycleCtrl.currentCycle['role']?.toString() == 'viewer';

  String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.round().toString();
    }
    return weight.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  void initState() {
    super.initState();
    cycleCtrl = Get.find<CycleController>();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colorScheme = Theme.of(context).colorScheme;
      final isDark = colorScheme.brightness == Brightness.dark;
      final entries = cycleCtrl.getAverageWeightEntries();
      final lastEntry = entries.isNotEmpty ? entries.last : null;
      final sortedEntries = List<WeightEntry>.from(entries)
        ..sort((a, b) => b.date.compareTo(a.date));

      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme, isDark, entries),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            if (lastEntry != null && !_isHistoryExpanded.value)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  child: WeightEntryRow(
                    entry: lastEntry,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    isViewer: _isViewer,
                    formatWeight: _formatWeight,
                    onDelete: () => showDeleteWeightDialog(
                      entry: lastEntry,
                      formatWeight: _formatWeight,
                      onConfirm: () =>
                          cycleCtrl.removeAverageWeightEntry(lastEntry.id),
                    ),
                  ),
                ),
              ),
            if (_isHistoryExpanded.value && entries.isNotEmpty)
              WeightEntryHistoryList(
                sortedEntries: sortedEntries,
                colorScheme: colorScheme,
                isDark: isDark,
                isViewer: _isViewer,
                formatWeight: _formatWeight,
                onDelete: (entry) => showDeleteWeightDialog(
                  entry: entry,
                  formatWeight: _formatWeight,
                  onConfirm: () =>
                      cycleCtrl.removeAverageWeightEntry(entry.id),
                ),
              ),
            if (!_isViewer) _buildInputSection(colorScheme, isDark),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(
      ColorScheme colorScheme, bool isDark, List<WeightEntry> entries) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.03),
                  Colors.transparent,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.15),
                  colorScheme.primary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Icon(
              Icons.monitor_weight,
              color: colorScheme.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'متوسط وزن القطيع',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.1,
                color: colorScheme.primary,
              ),
            ),
          ),
          if (entries.length > 1)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _isHistoryExpanded.value =
                      !_isHistoryExpanded.value;
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: _isHistoryExpanded.value
                        ? colorScheme.primary.withValues(alpha: 0.3)
                        : colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color:
                          colorScheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _isHistoryExpanded.value
                        ? Icons.expand_less_rounded
                        : Icons.history_rounded,
                    size: 14.sp,
                    color: colorScheme.primary,
                    shadows: [
                      Shadow(
                        color:
                            Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputSection(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : LinearGradient(
                colors: [
                  Colors.transparent,
                  colorScheme.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [ArabicToEnglishDigitsFormatter()],
              decoration: InputDecoration(
                hintText: 'أدخل متوسط وزن القطيع',
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                suffixText: 'كيلو',
                suffixStyle: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Material(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(10.r),
            elevation: 2,
            shadowColor: colorScheme.primary
                .withValues(alpha: 0.3),
            child: InkWell(
              onTap: () {
                final value = _controller.text;
                final weight = tryParseNum(value) ?? 0.0;
                if (weight > 0) {
                  _save();
                } else {
                  _controller.clear();
                }
              },
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary
                          .withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary
                          .withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.onPrimary,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    final weight = tryParseNum(value) ?? 0.0;
    if (weight <= 0) return;
    await cycleCtrl.addAverageWeightEntry(weight);
    _controller.clear();
  }
}
