import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/constant/routes/route.dart';
import '../../../../../core/constant/theme/color.dart';
import '../../../../../data/model/disease_model/disease_model.dart';

Widget buildDiseaseAnswer(DiseaseModel disease, Map<String, String> answers) {
  return SingleChildScrollView(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 21,
                color: AppColor.primaryColor,
              ),
              onPressed: () {
                Get.offNamed(AppRoute.diseaseDetails, arguments: disease);
              },
            ),
            Text(
              "المرض : ${disease.name}",
              style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 31),
        Directionality(
          textDirection: TextDirection.rtl,
          child: ExpansionTile(
            title: Text(
              "تفاصيل الاجابات",
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
            children: answers.entries.map((entry) {
              return ListTile(
                title: Text(
                  entry.key,
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  entry.value,
                  style: TextStyle(fontSize: 13.sp),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}
