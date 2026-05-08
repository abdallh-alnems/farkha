import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/theme/theme.dart';
import '../../widget/cycle/closeout/closeout_data.dart';
import '../../widget/cycle/closeout/closeout_cards.dart';
import '../../widget/cycle/closeout/closeout_financial.dart';
import '../../widget/cycle/closeout/closeout_sections.dart';

class CloseoutReportScreen extends StatelessWidget {
  final Map<String, dynamic> cycleData;

  const CloseoutReportScreen({super.key, required this.cycleData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = calculateCloseoutData(cycleData);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackGroundColor : AppColors.lightPageBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CloseoutHeader(data: data, isDark: isDark),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 100.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                closeoutSectionTitle('معلومات الدورة', isDark),
                SizedBox(height: 10.h),
                CloseoutInfoCard(data: data, isDark: isDark),
                SizedBox(height: 24.h),
                closeoutSectionTitle('أداء القطيع', isDark),
                SizedBox(height: 10.h),
                CloseoutPerformanceRow(data: data, isDark: isDark),
                CloseoutBenchmarkRow(data: data, isDark: isDark),
                SizedBox(height: 24.h),
                closeoutSectionTitle('مؤشرات الأداء', isDark),
                SizedBox(height: 10.h),
                CloseoutKpiGrid(data: data, isDark: isDark),
                SizedBox(height: 24.h),
                closeoutSectionTitle('المالية', isDark),
                SizedBox(height: 10.h),
                CloseoutFinancialSummary(data: data, isDark: isDark),
                SizedBox(height: 32.h),
                CloseoutExportSection(cycleData: cycleData),
                SizedBox(height: 24.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
