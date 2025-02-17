import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/constant/routes/route.dart';
import '../../../../../core/constant/theme/color.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 11),
      color: AppColor.secondaryColor,
      child: ListTile(
        title: Text(
          "تشخيص المرض",
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        leading:
            const Icon(Icons.arrow_back_ios, size: 17, color: Colors.black),
            onTap: () => Get.toNamed(AppRoute.questionDisease),
      ),
    );
  }
}
