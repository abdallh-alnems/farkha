import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_helpers.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/input_field.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/tools/tool_result_card.dart';
import '../../../logic/controller/tools_controller/fan_operation_controller.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tool_page_scaffold.dart';

class FanOperationScreen extends StatefulWidget {
  const FanOperationScreen({super.key});

  @override
  State<FanOperationScreen> createState() => _FanOperationScreenState();
}

class _FanOperationScreenState extends State<FanOperationScreen> {
  final FanOperationController controller = Get.put(FanOperationController());
  final TextEditingController temperatureController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showResult = false;
  bool _isLoadingTemperature = false;

  @override
  void dispose() {
    temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: FanOperationScreen, toolId: 9);
    final resultColor = getToolResultColor(context);

    return ToolPageScaffold(
      title: 'تشغيل الشفاطات',
      inputChild: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          children: [
            TwoInputFields(
              firstLabel: 'عدد الطيور',
              secondLabel: 'متوسط الوزن',
              secondHint: 'وزن الفرخ الواحد',
              secondSuffix: 'كجم',
              onFirstChanged: controller.updateNumberOfBirds,
              onSecondChanged: controller.updateAverageWeight,
            ),
            SizedBox(height: 11.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InputField(
                    label: 'سعة المروحة',
                    suffixText: 'م³/س',
                    onChanged: controller.updateFanCapacityPerHour,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InputField(
                        label: 'درجة الحرارة',
                        onChanged: controller.updateTemperature,
                        controller: temperatureController,
                        suffixText: _isLoadingTemperature ? null : '°C',
                        suffixIcon: _isLoadingTemperature
                            ? Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: SizedBox(
                                  width: 13,
                                  height: 13,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      resultColor,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        suffixIconConstraints: _isLoadingTemperature
                            ? const BoxConstraints.tightFor(
                                width: 20,
                                height: 20,
                              )
                            : null,
                      ),
                      SizedBox(height: 7.h),
                      FilledButton.icon(
                        onPressed: _isLoadingTemperature
                            ? null
                            : () => _fetchWeather(resultColor),
                        icon: Icon(Icons.thermostat, size: 13.sp),
                        label: Text(
                          'الحصول على درجة الحرارة',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: resultColor.withValues(
                            alpha:
                                Theme.of(context).brightness == Brightness.dark
                                    ? 0.2
                                    : 0.12,
                          ),
                          foregroundColor: resultColor,
                          padding: EdgeInsets.symmetric(
                            vertical: 10.h,
                            horizontal: 8.w,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimens.borderSm,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      buttonText: 'حساب تشغيل الشفاطات',
      onButtonPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          if (controller.temperature.value > 0) {
            controller.calculateFanOperation();
            setState(() => showResult = true);
          }
        }
      },
      footerSections: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutQuart,
          child: showResult
              ? _FanResults(
                  controller: controller,
                  resultColor: resultColor,
                )
              : const SizedBox.shrink(),
        ),
        SizedBox(height: 24.h),
        const RelatedArticlesSection(relatedArticleIds: [5, 6]),
      ],
    );
  }

  Future<void> _fetchWeather(Color resultColor) async {
    setState(() => _isLoadingTemperature = true);
    try {
      final locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        if (!mounted) return;
        setState(() => _isLoadingTemperature = false);
        return;
      }

      await controller.getWeatherData();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _isLoadingTemperature = false);

      final hasData = controller.hasWeatherData;
      final temp = controller.currentTemperature;
      if (hasData && temp > 0) {
        final temperatureValue = temp.round().toString();
        setState(() => temperatureController.text = temperatureValue);
        controller.updateTemperature(temperatureValue);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingTemperature = false);
    }
  }
}

class _FanResults extends StatelessWidget {
  final FanOperationController controller;
  final Color resultColor;

  const _FanResults({
    required this.controller,
    required this.resultColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return Column(
        key: const ValueKey('fan_results'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
              borderRadius: AppDimens.borderLg,
              border: Border.all(
                color: resultColor.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.air, size: 32.sp, color: resultColor),
                SizedBox(height: 10.h),
                Text(
                  controller.operationStatus.value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: resultColor,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          ToolResultCard(
            title: 'كمية الهواء لكل كجم',
            value:
                '${formatDecimal(controller.airFlowPerKg.value)} م³/ساعة',
            resultColor: resultColor,
          ),
          ToolResultCard(
            title: 'كمية الهواء المطلوبة',
            value:
                '${formatDecimal(controller.requiredAirFlowPerHour.value, decimals: 0)} م³/ساعة',
            resultColor: resultColor,
          ),
          ToolResultCard(
            title: 'قدرة الشفاط في الدقيقة',
            value:
                '${formatDecimal(controller.fanCapacityPerMinute.value, decimals: 0)} م³/دقيقة',
            resultColor: resultColor,
          ),
        ],
      );
    });
  }
}
