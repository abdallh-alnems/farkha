import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/constant/theme/color.dart';
import '../../../logic/controller/price_controller/farkh_abid_controller.dart';

class CardPriceFarkhAbidHome extends StatelessWidget {
  const CardPriceFarkhAbidHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15).r,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.secondaryColor,
              AppColor.secondaryColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.secondaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: GetBuilder<FarkhAbidController>(
          builder:
              (controller) => Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  children: [
                    // العنوان
                    Text(
                      "أسعار الفراخ البيضاء",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),

                    // الأسعار الأربعة
                    HandlingDataView(
                      statusRequest: controller.statusRequest,
                      widget: Column(
                        children: [
                          // لحم أبيض
                          _buildPriceRow(
                            context,
                            "لحم أبيض",
                            controller.farkhAbidHigherToday,
                            controller.farkhAbidLowerToday,
                            const Color(0xFF4CAF50),
                            controller.farkhAbidPriceDifference,
                          ),
                          SizedBox(height: 8.h),
                          // فراخ بيضاء حية
                          _buildPriceRow(
                            context,
                            "فراخ بيضاء حية",
                            controller.frakhAbdiHayaHigherToday,
                            controller.frakhAbdiHayaLowerToday,
                            const Color(0xFF2196F3),
                            controller.frakhAbdiHayaPriceDifference,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String title,
    String higherPrice,
    String lowerPrice,
    Color color,
    double priceDifference,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          // الفرق (على اليسار)
          Expanded(
            child: Column(
              children: [
                Text(
                  "التغير",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  "${priceDifference.abs().toInt()}${priceDifference >= 0 ? '+' : '-'}",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          // السعر الأعلى
          Expanded(
            child: Column(
              children: [
                Text(
                  "أعلى",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  higherPrice,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          // السعر الأدنى
          Expanded(
            child: Column(
              children: [
                Text(
                  "أدنى",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  lowerPrice,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          // العنوان (على اليمين)
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
