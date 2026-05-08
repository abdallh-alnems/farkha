import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/model/disease_model/disease_model.dart';
import '../../../widget/ad/banner.dart';
import '../../../widget/ad/native.dart';
import '../../../widget/appbar/custom_appbar.dart';
import '../../../widget/tools/disease/disease_details.dart';

class DiseaseDetails extends StatelessWidget {
  const DiseaseDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final DiseaseModel disease = Get.arguments as DiseaseModel;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(text: disease.name),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 16.w,
                    ),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.coronavirus_outlined,
                            size: 24.sp,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            disease.name,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AdNativeWidget(),
                  SizedBox(height: 16.h),
                  buildSection(
                    'الأعراض',
                    buildCriteriaList(disease.criteria),
                    icon: Icons.visibility_outlined,
                  ),
                  buildSection(
                    'العلاج',
                    buildList(disease.treatment),
                    icon: Icons.medication_outlined,
                  ),
                  buildSection(
                    'الوقاية',
                    buildList(disease.prevention),
                    icon: Icons.shield_outlined,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
