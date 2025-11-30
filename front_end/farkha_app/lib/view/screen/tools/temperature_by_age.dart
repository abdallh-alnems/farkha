import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/temperature_by_age_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/age_dropdown.dart';

class TemperatureByAgeScreen extends StatefulWidget {
  const TemperatureByAgeScreen({super.key});

  @override
  State<TemperatureByAgeScreen> createState() => _TemperatureByAgeScreenState();
}

class _TemperatureByAgeScreenState extends State<TemperatureByAgeScreen> {
  final TemperatureByAgeController controller = Get.put(
    TemperatureByAgeController(),
  );
  bool showResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'درجة الحرارة حسب العمر'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                maxAge: 45,
                hint: 'اختر اليوم',
              ),
              const SizedBox(height: 20),
              const AdNativeWidget(),
              const SizedBox(height: 20),
              if (showResult)
                Obx(() {
                  final temperature = controller.temperature.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'درجة الحرارة : °$temperature',
                        style: const TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
