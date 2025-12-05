import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/chicken_age_count_input.dart';
import '../../widget/tools/broiler_chicken_requirements/items_broiler_chicken_requirements.dart';

class BroilerChickenRequirements extends StatelessWidget {
  BroilerChickenRequirements({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final BroilerController controller = Get.put(BroilerController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "متطلبات فراخ التسمين"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(13),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AdNativeWidget(),
                    const SizedBox(height: 21),
                    Obx(
                      () => ChickenAgeCountInput(
                        controller: controller.chickensCountController,
                        selectedAge: controller.selectedChickenAge.value,
                        onAgeChanged: (newValue) {
                          controller.selectedChickenAge.value = newValue;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            controller.onPressed();
                          }
                        },
                        child: const Text("متطلبات فراخ التسمين"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ItemsBroilerChickenRequirements(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
