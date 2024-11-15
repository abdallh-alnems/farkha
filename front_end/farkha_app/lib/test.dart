import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/color.dart';
import '../../../logic/controller/calculate_controller/feed_consumption.dart';
import 'view/widget/app_bar/custom_app_bar.dart';

class FeedConsumption extends StatelessWidget {
  const FeedConsumption({super.key});

  @override
  Widget build(BuildContext context) {
    final FeedConsumptionController controller =
        Get.put(FeedConsumptionController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(text: "استهلاك العلف"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19).r,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColor.primaryColor,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.isCumulative.value = false;
                      controller.resetInputs();
                    },
                    child: Obx(() {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: !controller.isCumulative.value
                              ? AppColor.primaryColor
                              : Colors.transparent,
                        ),
                        child: Text(
                          'يومي',
                          style: TextStyle(
                            color: !controller.isCumulative.value
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      controller.isCumulative.value = true;
                      controller.resetInputs();
                    },
                    child: Obx(() {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: controller.isCumulative.value
                              ? AppColor.primaryColor
                              : Colors.transparent,
                        ),
                        child: Text(
                          'تراكمي',
                          style: TextStyle(
                            color: controller.isCumulative.value
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Obx(() {
                    if (controller.isCumulative.value) {
                      return SizedBox.shrink();
                    } else {
                      return DropdownButtonFormField<int>(
                        value: controller.selectedAge.value,
                        onChanged: (int? newValue) {
                          controller.selectedAge.value = newValue;
                        },
                        decoration: InputDecoration(
                          labelText: 'اختار العمر (بالأيام)',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            List.generate(45, (index) => index + 1).map((age) {
                          return DropdownMenuItem<int>(
                            value: age,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('$age يوم'),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  }),
                  SizedBox(height: 16),
                  TextField(
                    controller: controller.countController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'أدخل عدد الدواجن',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.calculateFeedConsumption,
                    child: Text('حساب الاستهلاك'),
                  ),
                  SizedBox(height: 16),
                  Obx(() {
                    return Text(
                      controller.result.value,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
