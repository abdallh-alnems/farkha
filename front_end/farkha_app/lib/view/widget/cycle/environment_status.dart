// lib/ui/widget/cycle/environment_status.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/color.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../../logic/controller/weather_controller.dart';

class EnvironmentStatus extends StatelessWidget {
  const EnvironmentStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final broilerCtrl = Get.find<BroilerController>();
    final weatherCtrl = Get.find<WeatherController>();
    final cycleCtrl = Get.find<CycleController>();

    return Obx(() {
      if (cycleCtrl.currentCycle.isEmpty) {
        return const SizedBox();
      }

      final isLoading = weatherCtrl.statusRequest != StatusRequest.success;
      final currTemp = weatherCtrl.currentTemperature.value;
      final currHum = weatherCtrl.currentHumidity.value.toDouble();
      final targTemp = broilerCtrl.ageTemperature.value.toDouble();
      final parts = broilerCtrl.ageHumidityRange.split('-');
      final targHum = double.tryParse(parts.last.replaceAll('%', '')) ?? 0.0;

      return Container(
        height: 121.h,
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Row(
          children: [
            _buildSection(
              icon: WeatherIcons.humidity,
              title: 'رطوبة الطقس',
              currentValue: isLoading ? '-' : '${currHum.toStringAsFixed(0)}%',
              targetValue: '${targHum.toStringAsFixed(0)}%',
            ),
            Container(width: 1.w, height: 55.h, color: Colors.white54),
            _buildSection(
              icon: WeatherIcons.thermometer,
              title: 'حرارة الطقس',
              currentValue:
                  isLoading ? '-' : '${currTemp.toStringAsFixed(0)}°C',
              targetValue: '${targTemp.toStringAsFixed(0)}°C',
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
    required String targetValue,
  }) {
    return Expanded(
      child: Column(
        children: [
          BoxedIcon(icon, color: Colors.white, size: 24),
          SizedBox(height: 4.h),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 13.sp)),
          SizedBox(height: 9.h),
          Container(height: 1.h, width: 99.w, color: Colors.white54),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentValue,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'الحالية',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1.w, height: 23.h, color: Colors.white54),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        targetValue,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'المطلوبة',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
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
