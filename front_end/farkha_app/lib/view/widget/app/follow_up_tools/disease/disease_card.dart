import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/constant/routes/route.dart';
import '../../../../../core/constant/theme/color.dart';
import '../../../../../data/data_source/static/disease/disease_data.dart';

class DiseaseCard extends StatelessWidget {
  const DiseaseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: diseases.map((disease) {
        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 11),
          color: AppColor.primaryColor,
          child: ListTile(
            title: Text(
              disease.name,
              style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textDirection: TextDirection.rtl,
            ),
            leading:
                const Icon(Icons.arrow_back_ios, size: 17, color: Colors.white),
            onTap: () =>
                Get.toNamed(AppRoute.diseaseDetails, arguments: disease),
          ),
        );
      }).toList(),
    );
  }
}
