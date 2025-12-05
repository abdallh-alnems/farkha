import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../data/data_source/static/disease/disease_data.dart';

class DiseaseCard extends StatelessWidget {
  const DiseaseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          diseases.map((disease) {
            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 11),
              color: AppColors.primaryColor,
              child: InkWell(
                onTap:
                    () => Get.toNamed(
                      AppRoute.diseaseDetails,
                      arguments: disease,
                    ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 23,
                  ),
                  child: Row(
                    children: [
                      Transform.scale(
                        scaleX: -1,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 17.sp,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            disease.name,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
