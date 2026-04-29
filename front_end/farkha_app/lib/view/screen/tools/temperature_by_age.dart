import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/constant/theme/images.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../logic/controller/tools_controller/temperature_by_age_controller.dart';
import '../../../logic/controller/weather_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../../core/shared/input_fields/age_dropdown.dart';
import '../../widget/tools/related_articles_section.dart';

class TemperatureByAgeScreen extends StatefulWidget {
  const TemperatureByAgeScreen({super.key});

  @override
  State<TemperatureByAgeScreen> createState() => _TemperatureByAgeScreenState();
}

class _TemperatureByAgeScreenState extends State<TemperatureByAgeScreen> {
  late final TemperatureByAgeController controller;
  late final WeatherController weatherController;

  bool showResult = false;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<TemperatureByAgeController>()) {
      Get.put(TemperatureByAgeController());
    }
    if (!Get.isRegistered<WeatherController>()) {
      Get.put(WeatherController(), permanent: true);
    }
    controller = Get.find<TemperatureByAgeController>();
    weatherController = Get.find<WeatherController>();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: TemperatureByAgeScreen, toolId: 7);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final resultColor =
        isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;

    return Scaffold(
      appBar: const CustomAppBar(text: 'درجة الحرارة حسب العمر', favoriteToolName: 'درجة الحرارة حسب العمر'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AgeDropdown(
                selectedAge: controller.selectedAge.value,
                onAgeChanged: (value) {
                  controller.selectedAge.value = value;
                  controller.calculateTemperature();
                  setState(() {
                    showResult = true;
                  });
                },
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              if (showResult)
                Obx(() {
                  final temperature = controller.temperature.value;
                  final ambientTemp = weatherController.currentTemperature.value;
                  final weatherStatus = weatherController.statusRequest.value;
                  if (temperature <= 0) return const SizedBox.shrink();

                  Widget ambientContent;
                  if (weatherStatus == StatusRequest.loading) {
                    ambientContent = Row(
                      children: [
                        Text(
                          'درجة حرارة الجو: ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Lottie.asset(
                              AppImages.loading,
                              width: 50.w,
                              height: 50.h,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (weatherController.hasWeatherData) {
                    ambientContent = Text(
                      'درجة حرارة الجو: °${formatDecimal(ambientTemp, decimals: 0)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  } else {
                    ambientContent = Text(
                      'درجة حرارة الجو: فعّل صلاحية الموقع',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          resultColor.withValues(alpha: isDark ? 0.22 : 0.1),
                          resultColor.withValues(alpha: isDark ? 0.12 : 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: resultColor.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'درجة الحرارة المطلوبة',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '°$temperature',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: resultColor,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          decoration: BoxDecoration(
                            color: resultColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: resultColor.withValues(alpha: 0.3),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.thermostat,
                                color: resultColor,
                                size: 22.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(child: ambientContent),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const RelatedArticlesSection(
                relatedArticleIds: [14, 11],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
