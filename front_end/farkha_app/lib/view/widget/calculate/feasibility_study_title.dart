import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../logic/controller/calculate_controller/feasibility_study_controller.dart';

class FeasibilityStudyTitle extends GetView<FeasibilityController> {
  final String title;
  const FeasibilityStudyTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7).r,
      child: Text(
        controller.profitResult.value == "" ? "" : title,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
