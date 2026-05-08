import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../data/data_source/static/disease/disease_data.dart';
import '../../../../data/model/disease_model/disease_model.dart';

class DiseaseCard extends StatelessWidget {
  const DiseaseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            'دليل الأمراض',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: diseases
              .map((disease) => _DiseaseChip(disease: disease))
              .toList(),
        ),
      ],
    );
  }
}

class _DiseaseChip extends StatelessWidget {
  const _DiseaseChip({required this.disease});

  final DiseaseModel disease;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final surfaceColor = isDark
        ? AppColors.darkSurfaceElevatedColor
        : AppColors.lightSurfaceColor;
    final borderColor = isDark
        ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
        : AppColors.lightOutlineColor.withValues(alpha: 0.4);

    return SizedBox(
      width: (1.sw - 32.w - 10.w) / 2,
      child: Card(
        elevation: isDark ? 0 : 1.5,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: () => Get.toNamed<void>(
            AppRoute.diseaseDetails,
            arguments: disease,
          ),
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            child: Text(
              disease.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
