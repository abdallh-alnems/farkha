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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkSurfaceElevatedColor : AppColors.primaryColor;
    final textColor = isDark
        ? AppColors.darkPrimaryColor
        : Colors.white;

    return Column(
      children: [
        for (int i = 0; i < diseases.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: 11.h),
            child: Row(
              children: [
                Expanded(
                  child: _buildCard(
                    context,
                    disease: diseases[i],
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: i + 1 < diseases.length
                      ? _buildCard(
                          context,
                          disease: diseases[i + 1],
                          cardColor: cardColor,
                          textColor: textColor,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static const double _cardHeight = 82;

  Widget _buildCard(
    BuildContext context, {
    required DiseaseModel disease,
    required Color cardColor,
    required Color textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.darkPrimaryColor.withValues(alpha: 0.4)
        : AppColors.primaryColor.withValues(alpha: 0.3);

    return Card(
      elevation: isDark ? 0 : 2,
      color: cardColor,
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
        child: SizedBox(
          height: _cardHeight.h,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  disease.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
