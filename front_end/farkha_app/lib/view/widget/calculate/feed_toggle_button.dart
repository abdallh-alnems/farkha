import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constant/theme/color.dart';
import '../../../logic/controller/calculate_controller/feed_consumption_controller.dart';

class FeedToggleButtons extends GetView<FeedConsumptionController> {
  const FeedToggleButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 13).r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColor.primaryColor,
          width: 2,
        ),
      ),
      child: Obx(() {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleButton(
              label: 'يومي',
              isActive: !controller.isCumulative.value,
            ),
            ToggleButton(
              label: 'تراكمي',
              isActive: controller.isCumulative.value,
            ),
          ],
        );
      }),
    );
  }
}

class ToggleButton extends GetView<FeedConsumptionController> {
  final String label;
  final bool isActive;

  const ToggleButton({
    super.key,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.resetInputs,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6).r,
        decoration: BoxDecoration(
          color: isActive ? AppColor.primaryColor : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
