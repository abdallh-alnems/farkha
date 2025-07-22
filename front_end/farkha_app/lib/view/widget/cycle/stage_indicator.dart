import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/theme/color.dart';

class StageIndicator extends StatelessWidget {
  final String startDateRaw;

  const StageIndicator({super.key, required this.startDateRaw});

  static const List<String> _labels = ['التربية', 'التسمين', 'البيع'];

  int _getStageIndex(int days) {
    if (days <= 14) return 0;
    if (days <= 30) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.tryParse(startDateRaw);
    final ageDays =
        startDate == null ? 0 : DateTime.now().difference(startDate).inDays;
    final currentStage = _getStageIndex(ageDays);

    Color circleColor(int idx) =>
        idx <= currentStage ? AppColor.primaryColor : AppColor.secondaryColor;

    Color lineColor(int idx) =>
        idx < currentStage ? AppColor.primaryColor : AppColor.secondaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: List.generate(_labels.length * 2 - 1, (idx) {
            if (idx.isEven) {
              final s = idx ~/ 2;
              return Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Container(
                    width: 80.w,
                    padding: EdgeInsets.symmetric(
                      vertical: 6.h,
                      horizontal: 6.w,
                    ),
                    decoration: BoxDecoration(
                      color: circleColor(s),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Center(
                      child: Text(
                        _labels[s],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }
            final li = (idx - 1) ~/ 2;
            return Expanded(
              flex: 1,
              child: Container(height: 2.h, color: lineColor(li)),
            );
          }),
        ),
      ),
    );
  }
}
