import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../logic/controller/tools_controller/fan_operation_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/tools_button.dart';

class FanOperationScreen extends StatefulWidget {
  const FanOperationScreen({super.key});

  @override
  State<FanOperationScreen> createState() => _FanOperationScreenState();
}

class _FanOperationScreenState extends State<FanOperationScreen> {
  final FanOperationController controller = Get.put(FanOperationController());
  bool showResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'حساب تشغيل الشفاطات',
        toolKey: 'fanOperationDialog',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TwoInputFields(
                        firstLabel: 'عدد الطيور',
                        secondLabel: 'متوسط الوزن (كجم)',
                        onFirstChanged: controller.updateNumberOfBirds,
                        onSecondChanged: controller.updateAverageWeight,
                      ),
                      SizedBox(height: 12.h),
                      TwoInputFields(
                        firstLabel: 'سعة المروحة (م³/ساعة)',
                        secondLabel: 'درجة الحرارة الحالية',
                        onFirstChanged: controller.updateFanCapacityPerHour,
                        onSecondChanged:
                            (value) {}, // لا نحتاج تحديث درجة الحرارة يدوياً
                      ),
                      SizedBox(height: 12.h),
                      // زر الحصول على درجة الحرارة
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await controller.getWeatherData();
                            if (controller.currentTemperature > 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم الحصول على درجة الحرارة: ${controller.currentTemperature.toStringAsFixed(1)}°C',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'فشل في الحصول على درجة الحرارة',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.location_on),
                          label: const Text('الحصول على درجة الحرارة الحالية'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // عرض درجة الحرارة الحالية
                      Obx(
                        () =>
                            controller.currentTemperature > 0
                                ? Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.thermostat,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'درجة الحرارة الحالية: ${controller.currentTemperature.toStringAsFixed(1)}°C',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                      SizedBox(height: 24.h),

                      // Calculate button
                      ToolsButton(
                        text: 'حساب تشغيل الشفاطات',
                        onPressed: () {
                          if (controller.currentTemperature > 0) {
                            controller.calculateFanOperation(context);
                            setState(() {
                              showResult = true;
                            });
                          } else {
                            // إظهار رسالة للمستخدم
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'يرجى الحصول على درجة الحرارة أولاً',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Ad widget
                      const AdNativeWidget(),
                      SizedBox(height: 24.h),

                      // Results section
                      if (showResult) _buildResultsSection(),
                    ],
                  ),
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
              'درجة الحرارة المستخدمة',
              '${controller.currentTemperature.toStringAsFixed(1)}°C',
            ),
            _buildResultRow(
              'الوزن الكلي للطيور',
              '${controller.totalWeight.value.toStringAsFixed(1)} كجم',
            ),
            _buildResultRow(
              'كمية الهواء لكل كجم',
              '${controller.airFlowPerKg.value.toStringAsFixed(1)} م³/ساعة',
            ),
            _buildResultRow(
              'كمية الهواء المطلوبة',
              '${controller.requiredAirFlowPerHour.value.toStringAsFixed(1)} م³/ساعة',
            ),
            _buildResultRow(
              'قدرة الشفاط في الدقيقة',
              '${controller.fanCapacityPerMinute.value.toStringAsFixed(1)} م³/دقيقة',
            ),
            _buildResultRow(
              'مدة التشغيل',
              '${controller.operationDuration.value.toStringAsFixed(1)} دقيقة',
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
                    textAlign: TextAlign.center,
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
}
