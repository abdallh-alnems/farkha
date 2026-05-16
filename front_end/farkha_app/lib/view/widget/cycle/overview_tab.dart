import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../../logic/controller/weather_controller.dart';
import '../../widget/ad/native.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  static const List<String> _stageLabels = ['تحضين', 'تسمين', 'بيع'];

  int _getStageIndex(int days) {
    if (days <= 14) return 0;
    if (days <= 30) return 1;
    return 2;
  }

  String _getPrecipitationDescription(double precip) {
    if (precip >= 7.6) return 'غزيرة';
    if (precip >= 2.6) return 'متوسطة';
    if (precip >= 0.1) return 'خفيفة';
    return 'لا أمطار';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cycleCtrl = Get.find<CycleController>();
    final broilerCtrl = Get.find<BroilerController>();
    final weatherCtrl = Get.isRegistered<WeatherController>()
        ? Get.find<WeatherController>()
        : Get.put(WeatherController());

    return Obx(() {
      final cycle = cycleCtrl.currentCycle;
      if (cycle.isEmpty) return const SizedBox.shrink();

      final startDateRaw = cycle['startDateRaw']?.toString() ?? '';
      final startDateParsed = DateTime.tryParse(startDateRaw);
      final ageDays = startDateParsed == null
          ? 0
          : DateTime.now().difference(startDateParsed).inDays;
      final safeAgeDays = ageDays < 0 ? 0 : ageDays;
      final currentStage = _getStageIndex(safeAgeDays);
      final ageText = cycleCtrl.ageOf(startDateRaw);

      final chickCount = int.tryParse(
              cycle['chickCount']?.toString() ??
                  cycle['chick_count']?.toString() ??
                  '0') ??
          0;
      final mortality =
          int.tryParse(cycle['mortality']?.toString() ?? '0') ?? 0;
      final liveChickCount = chickCount - mortality;
      final mortalityPct =
          chickCount > 0 ? (mortality / chickCount * 100) : 0.0;

      final weatherStatus = weatherCtrl.statusRequest.value;
      final isWeatherLoading = weatherStatus == StatusRequest.loading;
      final isLocationDenied = weatherCtrl.locationPermissionDenied.value;
      final hasWeather = weatherStatus == StatusRequest.success;
      final currTemp = weatherCtrl.currentTemperature.value;
      final currHum = weatherCtrl.currentHumidity.value.toDouble();
      final currPrecip = weatherCtrl.currentPrecipitation.value;
      final targTemp = broilerCtrl.ageTemperature.value.toDouble();
      final parts = broilerCtrl.ageHumidityRange.split('-');
      final targHumStr = parts.last.replaceAll('%', '');
      final targHum = double.tryParse(targHumStr) ?? 0.0;

      final surfaceColor =
          isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor;
      final dimColor =
          isDark ? AppColors.darkOutlineColor : AppColors.lightOutlineColor;
      final accentColor =
          isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
        child: Column(
          children: [
            // ── Stage Progress ──
            Container(
              padding:
                  EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: dimColor),
              ),
              child: Row(
                children: List.generate(
                    _stageLabels.length * 2 - 1, (idx) {
                  if (idx.isOdd) {
                    final li = (idx - 1) ~/ 2;
                    return Expanded(
                      child: Container(
                        height: 3.h,
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        decoration: BoxDecoration(
                          color: li < currentStage ? accentColor : dimColor,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    );
                  }
                  final s = idx ~/ 2;
                  final isCurrent = s == currentStage;
                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _stageLabels[s],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isCurrent
                                ? accentColor
                                : isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 16.h),
            const AdNativeWidget(),
            SizedBox(height: 16.h),

            // ── Quick Stats ──
            Row(
              children: [
                _statCell(Icons.calendar_today_outlined, 'العمر',
                    ageText.isEmpty || ageText == 'لم تبدأ' ? '-' : '$ageText يوم', null, isDark, surfaceColor, dimColor, accentColor),
                SizedBox(width: 8.w),
                _statCell(Icons.pets_outlined, 'المتبقي', '$liveChickCount', null, isDark, surfaceColor, dimColor, accentColor),
                SizedBox(width: 8.w),
                _statCell(
                  Icons.warning_amber_rounded,
                  'النافق',
                  '$mortality',
                  mortalityPct > 0 ? '${mortalityPct.round()}%' : null,
                  isDark,
                  surfaceColor,
                  dimColor,
                  mortalityPct > 5 ? AppColors.errorColor : accentColor,
                ),
                SizedBox(width: 8.w),
                _buildExpensesCell(isDark, surfaceColor, dimColor, accentColor),
              ],
            ),
            SizedBox(height: 16.h),

            // ── Environment ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: dimColor),
              ),
              child: isLocationDenied
                  ? SizedBox(
                      height: 72.h,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => weatherCtrl.refreshWeather(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_off_rounded, size: 24.sp, color: accentColor),
                              SizedBox(height: 8.h),
                              Text(
                                'فعّل صلاحية الموقع لعرض بيانات الطقس',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : isWeatherLoading
                      ? SizedBox(
                          height: 72.h,
                          child: Center(
                            child: SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: accentColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        )
                      : hasWeather
                          ? Row(
                              children: [
                                _envCompact(WeatherIcons.thermometer, 'الحرارة',
                                    '${currTemp.toStringAsFixed(0)}°',
                                    '${targTemp.toStringAsFixed(0)}°',
                                    isDark, accentColor, dimColor),
                                Container(width: 1.w, height: 48.h, color: dimColor),
                                _envCompact(WeatherIcons.humidity, 'الرطوبة',
                                    '${currHum.toStringAsFixed(0)}%',
                                    '${targHum.toStringAsFixed(0)}%',
                                    isDark, accentColor, dimColor),
                                Container(width: 1.w, height: 48.h, color: dimColor),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      BoxedIcon(WeatherIcons.rain, color: accentColor, size: 18),
                                      SizedBox(height: 4.h),
                                      Text('الأمطار',
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                      SizedBox(height: 6.h),
                                      Text(
                                        _getPrecipitationDescription(currPrecip),
                                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: accentColor, height: 1.1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 72.h,
                              child: Center(
                                child: SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: accentColor.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statCell(
    IconData icon,
    String label,
    String value,
    String? subtitle,
    bool isDark,
    Color surfaceColor,
    Color dimColor,
    Color accentColor,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: dimColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.sp, color: accentColor),
            SizedBox(height: 6.h),
            Text(label,
                style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                textAlign: TextAlign.center),
            SizedBox(height: 4.h),
            Text(value,
                style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    height: 1.1),
                textAlign: TextAlign.center),
            if (subtitle != null)
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.errorColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesCell(
    bool isDark,
    Color surfaceColor,
    Color dimColor,
    Color accentColor,
  ) {
    try {
      final expensesCtrl = Get.find<CycleExpensesController>();
      return Obx(() {
        final total = expensesCtrl.totalExpenses.value.round();
        return _statCell(Icons.payments_outlined, 'المصروفات', '$total', null,
            isDark, surfaceColor, dimColor, accentColor);
      });
    } catch (_) {
      return _statCell(Icons.payments_outlined, 'المصروفات', '0', null,
          isDark, surfaceColor, dimColor, accentColor);
    }
  }

  Widget _envCompact(
    IconData icon,
    String label,
    String current,
    String target,
    bool isDark,
    Color accentColor,
    Color dimColor,
  ) {
    final dimText = isDark ? Colors.grey[500] : Colors.grey[500];
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BoxedIcon(icon, color: accentColor, size: 18),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(current,
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            height: 1.1)),
                    SizedBox(height: 2.h),
                    Text('فعلي',
                        style: TextStyle(fontSize: 8.sp, color: dimText)),
                  ],
                ),
              ),
              Container(width: 1.w, height: 26.h, color: dimColor),
              Expanded(
                child: Column(
                  children: [
                    Text(target,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            height: 1.1)),
                    SizedBox(height: 2.h),
                    Text('مطلوبة',
                        style: TextStyle(fontSize: 8.sp, color: dimText)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
