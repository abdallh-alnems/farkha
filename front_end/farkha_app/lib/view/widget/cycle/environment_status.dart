// lib/ui/widget/cycle/environment_status.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../../logic/controller/weather_controller.dart';

class EnvironmentStatus extends StatelessWidget {
  const EnvironmentStatus({super.key});

  String _getPrecipitationDescription(double precip) {
    if (precip == 0) {
      return 'لا أمطار';
    } else if (precip >= 0.1 && precip <= 2.5) {
      return 'خفيفة';
    } else if (precip >= 2.6 && precip <= 7.5) {
      return 'متوسطة';
    } else if (precip >= 7.6) {
      return 'غزيرة';
    }
    return 'لا أمطار';
  }

  @override
  Widget build(BuildContext context) {
    final broilerCtrl = Get.find<BroilerController>();
    final weatherCtrl =
        Get.isRegistered<WeatherController>()
            ? Get.find<WeatherController>()
            : Get.put(WeatherController());
    final cycleCtrl = Get.find<CycleController>();

    return Obx(() {
      if (cycleCtrl.currentCycle.isEmpty) {
        return const SizedBox();
      }

      final isLoading = weatherCtrl.statusRequest != StatusRequest.success;
      final currTemp = weatherCtrl.currentTemperature.value;
      final currHum = weatherCtrl.currentHumidity.value.toDouble();
      final currPrecip = weatherCtrl.currentPrecipitation.value;
      final targTemp = broilerCtrl.ageTemperature.value.toDouble();
      final parts = broilerCtrl.ageHumidityRange.split('-');
      final targHum = double.tryParse(parts.last.replaceAll('%', '')) ?? 0.0;

      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return Container(
        height: 121.h,
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.lightCardBackgroundColor,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildSection(
              icon: WeatherIcons.humidity,
              title: 'رطوبة الطقس',
              currentValue: isLoading ? '-' : '${currHum.toStringAsFixed(0)}%',
              targetValue: '${targHum.toStringAsFixed(0)}%',
              isDark: isDark,
            ),
            Container(
              width: 1.w,
              height: 55.h,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            _buildSection(
              icon: WeatherIcons.thermometer,
              title: 'حرارة الطقس',
              currentValue:
                  isLoading ? '-' : '${currTemp.toStringAsFixed(0)}°C',
              targetValue: '${targTemp.toStringAsFixed(0)}°C',
              isDark: isDark,
            ),
            Container(
              width: 1.w,
              height: 55.h,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            _buildSection(
              icon: WeatherIcons.rain,
              title: 'الأمطار',
              currentValue:
                  isLoading ? '-' : _getPrecipitationDescription(currPrecip),
              targetValue: null,
              isDark: isDark,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String currentValue,
    String? targetValue,
    required bool isDark,
  }) {
    final iconColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final textColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final valueColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final dividerColor = isDark ? Colors.grey[700] : Colors.grey[300];

    return Expanded(
      child: Column(
        children: [
          BoxedIcon(icon, color: iconColor, size: 24),
          SizedBox(height: 4.h),
          Text(title, style: TextStyle(color: textColor, fontSize: 13.sp)),
          SizedBox(height: 9.h),
          Container(height: 1.h, width: 99.w, color: dividerColor),
          Expanded(
            child:
                targetValue != null
                    ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentValue,
                                style: TextStyle(
                                  color: valueColor,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'الحالية',
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1.w,
                          height: 23.h,
                          color: dividerColor,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                targetValue,
                                style: TextStyle(
                                  color: valueColor,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'المطلوبة',
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentValue,
                          style: TextStyle(
                            color: valueColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
