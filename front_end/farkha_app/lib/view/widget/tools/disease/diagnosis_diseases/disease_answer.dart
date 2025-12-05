import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constant/routes/route.dart';
import '../../../../../data/model/disease_model/disease_model.dart';

Widget buildDiseaseAnswer(DiseaseModel disease, Map<String, String> answers) {
  return SingleChildScrollView(
    child: Column(
      children: [
        Center(
          child: InkWell(
            onTap: () {
              Get.offNamed(AppRoute.diseaseDetails, arguments: disease);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "المرض : ",
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: disease.name,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 31),
        ExpansionTile(
          title: Text(
            "تفاصيل الاجابات",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
          children:
              answers.entries.map((entry) {
                return ListTile(
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    entry.value,
                    style: TextStyle(fontSize: 13.sp),
                  ),
                );
              }).toList(),
        ),
      ],
    ),
  );
}
