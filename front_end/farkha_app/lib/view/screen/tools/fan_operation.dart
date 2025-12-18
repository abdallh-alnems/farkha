import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/tools_controller/fan_operation_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/input_field.dart';
import '../../widget/input_fields/two_input_fields.dart';
import '../../widget/tools/tools_button.dart';

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
    return Scaffold(
      appBar: const CustomAppBar(text: 'حساب تشغيل الشفاطات'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ad widget
                    const AdNativeWidget(),
                    SizedBox(height: 21.h),
                    TwoInputFields(
                      firstLabel: 'عدد الطيور',
                      secondLabel: 'متوسط الوزن (كجم)',
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
                                suffixIcon:
                                    _isLoadingTemperature
                                        ? const Padding(
                                          padding: EdgeInsets.only(left: 6),
                                          child: SizedBox(
                                            width: 13,
                                            height: 13,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.primaryColor,
                                                  ),
                                            ),
                                          ),
                                        )
                                        : null,
                                suffixIconConstraints:
                                    _isLoadingTemperature
                                        ? const BoxConstraints.tightFor(
                                          width: 20,
                                          height: 20,
                                        )
                                        : null,
                              ),
                              SizedBox(height: 7.h),
                              FilledButton.icon(
                                onPressed:
                                    _isLoadingTemperature
                                        ? null
                                        : () async {
                                          setState(() {
                                            _isLoadingTemperature = true;
                                          });

                                          try {
                                            final locationStatus =
                                                await Permission
                                                    .location
                                                    .status;

                                            if (!locationStatus.isGranted) {
                                              if (!mounted) return;
                                              setState(() {
                                                _isLoadingTemperature = false;
                                              });
                                              return;
                                            }

                                            await controller.getWeatherData();
                                            await Future.delayed(
                                              const Duration(milliseconds: 500),
                                            );

                                            if (!mounted) return;

                                            setState(() {
                                              _isLoadingTemperature = false;
                                            });

                                            final hasData =
                                                controller.hasWeatherData;
                                            final temp =
                                                controller.currentTemperature;

                                            if (hasData && temp > 0) {
                                              final temperatureValue =
                                                  temp.round().toString();
                                              setState(() {
                                                temperatureController.text =
                                                    temperatureValue;
                                              });
                                              controller.updateTemperature(
                                                temperatureValue,
                                              );
                                            }
                                          } catch (_) {
                                            if (!mounted) return;
                                            setState(() {
                                              _isLoadingTemperature = false;
                                            });
                                          }
                                        },
                                icon: Icon(Icons.thermostat, size: 13.sp),
                                label: Text(
                                  'الحصول على درجة الحرارة',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor
                                      .withValues(alpha: 0.12),
                                  foregroundColor: AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10.h,
                                    horizontal: 8.w,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 23.h),

                    // Calculate button
                    ToolsButton(
                      text: 'حساب تشغيل الشفاطات',
                      onPressed: () {
                        // التحقق من صحة النموذج قبل الحساب
                        if (_formKey.currentState?.validate() ?? false) {
                          if (controller.temperature.value > 0) {
                            controller.calculateFanOperation();
                            setState(() {
                              showResult = true;
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 21.h),

                    // Results section
                    if (showResult) _buildResultsSection(),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 15.h),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildResultsSection() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'نتائج الحساب',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),

            _buildResultRow(
              'كمية الهواء لكل كجم',
              '${_formatNumber(controller.airFlowPerKg.value)} م³/ساعة',
            ),
            _buildResultRow(
              'كمية الهواء المطلوبة',
              '${_formatNumber(controller.requiredAirFlowPerHour.value)} م³/ساعة',
            ),
            _buildResultRow(
              'قدرة الشفاط في الدقيقة',
              '${_formatNumber(controller.fanCapacityPerMinute.value)} م³/دقيقة',
            ),

            SizedBox(height: 16.h),

            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.blue, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'حالة التشغيل',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    controller.operationStatus.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(0);
  }
}
