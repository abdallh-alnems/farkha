import 'package:flutter/material.dart';
import '../../../core/constant/image_asset.dart';
import '../../../core/package/snackbar_utils.dart';
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
                onTap: () {
                  SnackbarUtils.showSnackbar();
                },
                image: ImageAsset.chicksLab,
                text: "معامل الكتاكيت",
              ),
              BigCard(
                onTap: () {
                  SnackbarUtils.showSnackbar();
                },
                image: ImageAsset.feedMills,
                text: "شركات الاعلاف",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
