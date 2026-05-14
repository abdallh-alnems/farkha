import 'dart:math';

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
import '../../../logic/controller/tools_controller/fan_operation_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class FanOperationScreen extends StatefulWidget {
  const FanOperationScreen({super.key});

  @override
  State<FanOperationScreen> createState() => _FanOperationScreenState();
}

class _FanOperationScreenState extends State<FanOperationScreen>
    with SingleTickerProviderStateMixin {
  final FanOperationController controller = Get.put(FanOperationController());
  final TextEditingController temperatureController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoadingTemperature = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    temperatureController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: FanOperationScreen, toolId: 9);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resultColor = getToolResultColor(context);

    return Scaffold(
      appBar: const CustomAppBar(
        text: 'تشغيل الشفاطات',
        favoriteToolName: 'تشغيل الشفاطات',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputCard(resultColor),
                    SizedBox(height: 12.h),
                    const AdNativeWidget(),
                    SizedBox(height: 12.h),
                    ToolsButton(
                      text: 'حساب تشغيل الشفاطات',
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (controller.temperature.value > 0) {
                            controller.calculateFanOperation();
                            _tabController.animateTo(0);
                          }
                        }
                      },
                    ),
                    SizedBox(height: 14.h),
                    Obx(() {
                      if (!controller.hasCalculated.value) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          _buildTabBar(isDark, resultColor),
                          SizedBox(height: 14.h),
                        ],
                      );
                    }),
                    Obx(() {
                      if (!controller.hasCalculated.value) {
                        return const SizedBox.shrink();
                      }
                      return AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) {
                          if (_tabController.index == 1) {
                            return _TimerTab(
                              controller: controller,
                              resultColor: resultColor,
                            );
                          }
                          return _ResultsTab(
                            controller: controller,
                            resultColor: resultColor,
                          );
                        },
                      );
                    }),
                    SizedBox(height: 24.h),
                    const RelatedArticlesSection(relatedArticleIds: [5, 6]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildInputCard(Color resultColor) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppDimens.borderMd,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
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
                            alpha: Theme.of(context).brightness == Brightness.dark
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
    );
  }

  Widget _buildTabBar(bool isDark, Color resultColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark
              ? AppColors.darkOutlineColor
              : AppColors.lightOutlineColor,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: resultColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        padding: EdgeInsets.all(4.w),
        labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
        tabs: [
          Tab(
            height: 40.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.air, size: 16.sp),
                SizedBox(width: 4.w),
                const Text('النتائج', overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          ),
          Tab(
            height: 40.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16.sp),
                SizedBox(width: 4.w),
                const Text('المؤقت', overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          ),
        ],
      ),
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

class _ResultsTab extends StatelessWidget {
  final FanOperationController controller;
  final Color resultColor;

  const _ResultsTab({
    required this.controller,
    required this.resultColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      return Column(
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
          _resultTile(
            context,
            title: 'كمية الهواء لكل كجم',
            value: '${formatDecimal(controller.airFlowPerKg.value)} م³/ساعة',
          ),
          _resultTile(
            context,
            title: 'كمية الهواء المطلوبة',
            value:
                '${formatDecimal(controller.requiredAirFlowPerHour.value, decimals: 0)} م³/ساعة',
          ),
          _resultTile(
            context,
            title: 'قدرة الشفاط في الدقيقة',
            value:
                '${formatDecimal(controller.fanCapacityPerMinute.value, decimals: 0)} م³/دقيقة',
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 16.sp, color: resultColor),
              SizedBox(width: 6.w),
              Text(
                'برامج التشغيل',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(
              FanOperationController.presetPrograms.length,
              (i) {
                final program = FanOperationController.presetPrograms[i];
                final isSelected =
                    controller.selectedProgram.value == program;
                final isRecommended =
                    i == controller.recommendedProgramIndex.value;

                return GestureDetector(
                  onTap: () => controller.selectProgram(program),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? resultColor.withValues(alpha: isDark ? 0.2 : 0.1)
                          : colorScheme.surface,
                      borderRadius: AppDimens.borderMd,
                      border: Border.all(
                        color: isSelected
                            ? resultColor.withValues(alpha: 0.7)
                            : colorScheme.outline.withValues(alpha: 0.4),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isRecommended && !isSelected) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 14.sp,
                            color: resultColor,
                          ),
                          SizedBox(width: 3.w),
                        ],
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            size: 14.sp,
                            color: resultColor,
                          )
                        else
                          Icon(
                            Icons.schedule,
                            size: 14.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        SizedBox(width: 5.w),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                program.name,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? resultColor
                                      : colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                program.description,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (controller.selectedProgram.value != null) ...[
            SizedBox(height: 12.h),
            _buildSummary(context, isDark),
          ],
        ],
      );
    });
  }

  Widget _buildSummary(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    final program = controller.selectedProgram.value!;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: AppDimens.borderMd,
        border: Border.all(color: resultColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              context,
              label: 'الدورات',
              value: '${controller.totalCycles}',
              icon: Icons.repeat_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 30.h,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _summaryItem(
              context,
              label: 'الإجمالي',
              value: '${formatDecimal(controller.totalMinutes)} د',
              icon: Icons.timer_outlined,
              highlight: true,
            ),
          ),
          if (program.offMinutes > 0) ...[
            Container(
              width: 1,
              height: 30.h,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _summaryItem(
                context,
                label: 'إيقاف',
                value:
                    '${formatDecimal(controller.totalMinutes - controller.operationDuration.value)} د',
                icon: Icons.pause_circle_outline,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: highlight ? resultColor : colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: highlight ? resultColor : colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _resultTile(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: resultColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerTab extends StatelessWidget {
  final FanOperationController controller;
  final Color resultColor;

  const _TimerTab({
    required this.controller,
    required this.resultColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final program = controller.selectedProgram.value;

      if (program == null) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppDimens.borderLg,
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 40.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              SizedBox(height: 12.h),
              Text(
                'اختر برنامج تشغيل من تبويب النتائج',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              Text(
                'ثم عد هنا لتشغيل المؤقت',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        );
      }

      final isRunning = controller.isTimerRunning.value;
      final isRunPhase = controller.isTimerInRunPhase.value;
      final progress = controller.timerProgress;
      final phaseColor = isRunPhase ? resultColor : AppColors.secondaryColor;
      final phaseLabel = isRunPhase ? 'تشغيل' : 'إيقاف';
      final timerText = controller.formatTimerDuration(
        controller.timerRemaining.value,
      );
      final cycles = controller.timerCycleCount.value;

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              phaseColor.withValues(alpha: isDark ? 0.18 : 0.08),
              phaseColor.withValues(alpha: isDark ? 0.08 : 0.03),
            ],
          ),
          borderRadius: AppDimens.borderLg,
          border: Border.all(
            color: phaseColor.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  program.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: phaseColor.withValues(alpha: 0.2),
                    borderRadius: AppDimens.borderXl,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRunPhase
                            ? Icons.play_circle_filled
                            : Icons.pause_circle,
                        size: 14.sp,
                        color: phaseColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        phaseLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: phaseColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 150.w,
              height: 150.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.flip(
                    flipX: true,
                    child: CustomPaint(
                      size: Size(150.w, 150.w),
                      painter: _RingPainter(
                        progress: isRunning ? progress : 1.0,
                        color: phaseColor,
                        trackColor: colorScheme.outline.withValues(alpha: 0.15),
                        strokeWidth: 5.w,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerText,
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                          color: phaseColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'الدورة $cycles',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: _timerBtn(
                    context,
                    icon: isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    label: isRunning
                        ? 'إيقاف مؤقت'
                        : (controller.timerRemaining.value == Duration.zero
                            ? 'بدء'
                            : 'استئناف'),
                    color: phaseColor,
                    isPrimary: true,
                    onTap: isRunning
                        ? controller.pauseTimer
                        : (controller.timerRemaining.value == Duration.zero
                            ? controller.startTimer
                            : controller.resumeTimer),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _timerBtn(
                    context,
                    icon: Icons.stop_rounded,
                    label: 'إنهاء',
                    color: colorScheme.error,
                    isPrimary: false,
                    onTap: controller.stopTimer,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _timerBtn(
                    context,
                    icon: Icons.replay_rounded,
                    label: 'إعادة',
                    color: resultColor,
                    isPrimary: false,
                    onTap: () {
                      controller.stopTimer();
                      controller.startTimer();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _timerBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isPrimary
              ? color.withValues(alpha: isDark ? 0.25 : 0.15)
              : Theme.of(context).colorScheme.surface,
          borderRadius: AppDimens.borderMd,
          border: Border.all(
            color: isPrimary
                ? color.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: FittedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15.sp, color: color),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
