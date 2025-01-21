import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widget/app/calculate/calculate_result.dart';
import '../../../core/shared/chicken_form.dart';
import '../../../logic/controller/calculate_controller/feed_consumption_controller.dart';
import '../../widget/app/ad/banner/ad_second_banner.dart';
import '../../widget/app/app_bar/custom_app_bar.dart';
import '../../widget/app/calculate/feed_toggle_button.dart';

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
          FeedToggleButtons(),
          ChickenForm(
            controller: controller.textController,
            onChanged: (newValue) {
              controller.selectedAge.value = newValue;
              controller.calculateFeedConsumption();
            },
            selectedAge: controller.selectedAge.value,
            notShowDropdownButton: controller.isCumulative,
            items: List.generate(45, (index) => index + 1).map((age) {
              return DropdownMenuItem<int>(
                value: age,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$age يوم',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            }).toList(),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 33).r,
                child: Obx(
                  () => CalculateResult(
                    text: controller.result.value,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
