import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';

class CycleStatsBar extends StatelessWidget {
  CycleStatsBar({super.key});

  final controller = Get.find<CycleController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cycle = controller.currentCycle;
      final startRaw = cycle['startDateRaw'] ?? '';
      final DateTime? startDate =
          startRaw.isNotEmpty ? DateTime.tryParse(startRaw) : null;

      if (startDate != null && DateTime.now().isBefore(startDate)) {
        final datePart = DateFormat('MM-dd').format(startDate);
        final dayPart = DateFormat('EEEE', 'ar').format(startDate);
        final fullDate = '$datePart ($dayPart)';

        return Container(
          width: double.infinity,
          height: 55.h,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            'ستبدأ الدورة في : $fullDate',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      final ageText = controller.ageOf(startRaw);
      return Container(
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn('ADG', cycle['adg']?.toString() ?? '0'),
            _buildStatColumn('FCR', cycle['fcr']?.toString() ?? '0'),
            _buildStatColumn('النافق', cycle['mortality']?.toString() ?? '0'),
            _buildStatColumn(
              'عدد الفراخ',
              cycle['chickCount']?.toString() ?? '0',
            ),
            _buildStatColumn('العمر', ageText),
          ],
        ),
      );
    });
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
