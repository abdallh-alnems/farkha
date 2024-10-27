import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/theme/image_asset.dart';
import '../../../core/shared/custom_divider.dart';
import '../../../core/shared/card/big_card.dart';

class PointsOfSale extends StatelessWidget {
  const PointsOfSale({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDivider(
          text: "منافذ البيع",
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BigCard(
                image: AppImageAsset.chicksLab,
                text: "معامل الكتاكيت",
              ),
              BigCard(
                image: AppImageAsset.feedMills,
                text: "شركات الاعلاف",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
