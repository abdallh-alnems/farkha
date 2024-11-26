import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/shared/calculate_result.dart';
import '../../../core/shared/chicken_form.dart';
import '../../../logic/controller/calculate_controller/feed_consumption_controller.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/calculate/feed_toggle_button.dart';

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
          Expanded(
            child: SingleChildScrollView(
              child: ChickenForm(
                controller: controller.countController,
                onChanged: (newValue) {
                  controller.selectedAge.value = newValue;
                },
                selectedAge: controller.selectedAge.value,
                notShowDropdownButton: controller.isCumulative,
                items: List.generate(45, (index) => index + 1).map((age) {
                  return DropdownMenuItem<int>(
                    value: age,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('$age يوم'),
                    ),
                  );
                }).toList(),
                children: [
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
                  Obx(
                    () => CalculateResult(
                      text: controller.result.value,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
