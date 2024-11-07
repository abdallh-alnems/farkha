import 'package:farkha_app/core/constant/theme/color.dart';
import 'package:flutter/material.dart';

class PriceIndex extends StatelessWidget {
  final num? todayPrice;
  final num? yesterdayPrice;
  const PriceIndex({super.key, this.todayPrice, this.yesterdayPrice});

  @override
  Widget build(BuildContext context) {
    return todayPrice! > yesterdayPrice!
        ? Icon(
            Icons.arrow_upward,
            color: Colors.red,
          )
        : todayPrice! < yesterdayPrice!
            ? Icon(
                Icons.arrow_downward,
                color: Colors.green,
              )
            : Icon(
                Icons.horizontal_rule,
                color: AppColor.primaryColor,
              );
  }
}