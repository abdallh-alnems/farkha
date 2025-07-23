import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/shared/chicken_form.dart';
import '../../../logic/controller/follow_up_tools_controller/broiler_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/follow_up_tools/broiler_chicken_requirements/items_broiler_chicken_requirements.dart';

class BroilerChickenRequirements extends StatelessWidget {
  const BroilerChickenRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    final BroilerController controller = Get.put(BroilerController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(text: "متابعة فراخ التسمين"),
          ChickenForm(
            controller: controller.chickensCountController,
            onChanged: (newValue) {
              controller.selectedChickenAge.value = newValue;
            },
            selectedAge: controller.selectedChickenAge.value,
            showButton: true,
            buttonOnPressed: () {
              FocusScope.of(context).unfocus();
              controller.onPressed();
            },
            buttonText: "متطلبات فراخ التسمين",
            items: List.generate(45, (index) => index + 1).map((age) {
              return DropdownMenuItem<int>(
                value: age,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('$age يوم'),
                ),
              );
            }).toList(),
            children: const [
              ItemsBroilerChickenRequirements(),
              Padding(
                padding:  EdgeInsets.only(top: 11),
                child: AdNativeWidget(adIndex: 2),
              )
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(adIndex: 1),
    );
  }
}
