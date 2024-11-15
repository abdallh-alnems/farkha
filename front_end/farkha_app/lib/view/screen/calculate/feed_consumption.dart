import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/shared/custom_text_filed.dart';
import '../../../logic/controller/calculate_controller/feed_consumption.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/ad/native/ad_second_native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/calculate/toggle_button.dart';

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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19).r,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    children: [
                      FeedToggleButtons(),
                      AdSecondNative(),
                      CustomTextFiled(
                        controller: controller.countController,
                      ),
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
                              labelText: 'اختار العمر',
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(45, (index) => index + 1)
                                .map((age) {
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
                      Padding(
                        padding: const EdgeInsets.only(top: 19, bottom: 17).r,
                        child: ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            controller.calculateFeedConsumption();
                          },
                          child: Text('حساب الاستهلاك'),
                        ),
                      ),
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
            ),
          )
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
