import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/data_source/static/vaccination_data.dart';
import '../../../../data/model/cycle/medication_entry.dart';
import '../../../../logic/controller/cycle_controller.dart';
import 'medication/medication_dialogs.dart';
import 'medication/medication_history.dart';

class MedicationCard extends StatefulWidget {
  const MedicationCard({super.key});

  @override
  State<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard> {
  late final CycleController cycleCtrl;
  late final TextEditingController _controller;
  final _isHistoryExpanded = false.obs;
  final RxSet<String> _addedVaccinations = <String>{}.obs;
  final RxBool _isManualEntry = false.obs;

  bool get _isViewer =>
      cycleCtrl.currentCycle['role']?.toString() == 'viewer';

  @override
  void initState() {
    super.initState();
    cycleCtrl = Get.find<CycleController>();
    _controller = TextEditingController();
    _loadAddedVaccinations();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadAddedVaccinations() {
    final entries = cycleCtrl.getMedicationEntries();
    final allVaccinationNames =
        VaccinationData.vaccinationSchedule.map((v) => v.vaccineName).toSet();
    for (var entry in entries) {
      if (allVaccinationNames.contains(entry.text)) {
        _addedVaccinations.add(entry.text);
      }
    }
  }

  void _handleDeleteEntry(MedicationEntry entry) {
    showDeleteMedicationDialog(context, entry, () {
      final allVaccinationNames = VaccinationData.vaccinationSchedule
          .map((v) => v.vaccineName)
          .toSet();
      if (allVaccinationNames.contains(entry.text)) {
        _addedVaccinations.remove(entry.text);
      }
      cycleCtrl.removeMedicationEntry(entry.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colorScheme = Theme.of(context).colorScheme;
      final isDark = colorScheme.brightness == Brightness.dark;
      final entries = cycleCtrl.getMedicationEntries();
      final lastEntry = entries.isNotEmpty ? entries.last : null;
      final sortedEntries = List<MedicationEntry>.from(entries)
        ..sort((a, b) => b.date.compareTo(a.date));

      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.15),
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
            Container(
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
                        colors: isDark
                            ? [
                                colorScheme.primary
                                    .withValues(alpha: 0.2),
                                colorScheme.primary
                                    .withValues(alpha: 0.15),
                              ]
                            : [
                                colorScheme.primary
                                    .withValues(alpha: 0.15),
                                colorScheme.primary
                                    .withValues(alpha: 0.08),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Icon(
                      Icons.medication,
                      color: colorScheme.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'التحصينات',
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
                                ? colorScheme.primary
                                    .withValues(alpha: 0.3)
                                : isDark
                                    ? colorScheme.primary
                                        .withValues(alpha: 0.25)
                                    : colorScheme.primary
                                        .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.4),
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
            ),
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
                  child: MedicationEntryItem(
                    entry: lastEntry,
                    isDark: isDark,
                    showDelete: !_isViewer,
                    onDelete: () => _handleDeleteEntry(lastEntry),
                  ),
                ),
              ),
            if (_isHistoryExpanded.value && entries.isNotEmpty)
              MedicationHistoryList(
                sortedEntries: sortedEntries,
                isDark: isDark,
                isViewer: _isViewer,
                onDeleteEntry: _handleDeleteEntry,
              ),
            if (!_isViewer)
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? null
                      : LinearGradient(
                          colors: [Colors.transparent, colorScheme.primary.withValues(alpha: 0.02)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
                child: Obx(() {
                  final allVaccinations = VaccinationData.vaccinationSchedule;
                  final availableVaccinations = allVaccinations
                      .where(
                          (v) => !_addedVaccinations.contains(v.vaccineName))
                      .toList();

                  String? selectedVaccination;

                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: colorScheme.outline,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: selectedVaccination,
                          isExpanded: true,
                          hint: Text(
                            'اختر تحصين من القائمة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: colorScheme.primary,
                          ),
                          items: [
                            ...availableVaccinations.map((vaccination) {
                              return DropdownMenuItem<String>(
                                value: vaccination.vaccineName,
                                child: Text(
                                  '${vaccination.vaccineName} (عمر ${vaccination.age} يوم)',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              );
                            }),
                            DropdownMenuItem<String>(
                              value: 'manual',
                              child: Text(
                                'تحصين آخر',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == 'manual') {
                              _isManualEntry.value = true;
                              _controller.clear();
                            } else if (value != null) {
                              _addedVaccinations.add(value);
                              cycleCtrl.addMedicationEntry(value);
                              selectedVaccination = null;
                            }
                          },
                        ),
                      ),
                      if (_isManualEntry.value) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                          hintText: 'أدخل اسم التحصين',
                          hintStyle: TextStyle(fontSize: 12.sp, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
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
                                  if (value.isNotEmpty) {
                                    _save();
                                    _isManualEntry.value = false;
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
                                    borderRadius:
                                        BorderRadius.circular(10.r),
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
                      ],
                    ],
                  );
                }),
              ),
          ],
        ),
      );
    });
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    await cycleCtrl.addMedicationEntry(value);
    _controller.clear();
  }
}
