import 'package:flutter/material.dart';
import '../../../core/constant/theme/image_asset.dart';
import '../../../core/shared/custom_divider.dart';
import '../../../core/shared/card/small_card.dart';

class ViewCalculate extends StatelessWidget {
  const ViewCalculate({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDivider(
          text: "احسب",
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallCard(
                image: AppImageAsset.birdDensity,
                text: "كثافة الفراخ",
              ),
              SmallCard(
                image: AppImageAsset.feedConsumption,
                text: "استهلاك العلف",
              ),
              SmallCard(
                image: AppImageAsset.tableAnalysis,
                text: "دراسة جدول",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
