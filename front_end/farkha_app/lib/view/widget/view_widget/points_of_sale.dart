import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                onTap: () {
                  Get.snackbar(
                    '',
                    '',
                    titleText: const Text(
                      '',
                      style: TextStyle(fontSize: 0),
                      textAlign: TextAlign.center,
                    ),
                    messageText: const Text(
                      'قريبا',
                      style: TextStyle(fontSize: 23),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                image: ImageAsset.chicksLab,
                text: "معامل الكتاكيت",
              ),
              BigCard(
                onTap: () {
                  Get.snackbar(
                    '',
                    '',
                    titleText: const Text(
                      '',
                      style: TextStyle(fontSize: 0),
                      textAlign: TextAlign.center,
                    ),
                    messageText: const Text(
                      'قريبا',
                      style: TextStyle(fontSize: 23),
                      textAlign: TextAlign.center,
                    ),
                  );
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
