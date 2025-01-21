import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/theme/color.dart';
import '../../../core/shared/price_index.dart';

class PriceCard extends StatelessWidget {
  final String title;
  final int price;
  final int yesterdayPrice;

  final String priceDifference;

  const PriceCard(
      {super.key,
      required this.title,
      required this.price,
      required this.priceDifference,
      required this.yesterdayPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 249,
      height: 123,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(11)),
        color: AppColor.secondaryColor,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 39,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(11),
              ),
              color: AppColor.primaryColor,
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 7).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'المؤشر',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Container(
                        color: AppColor.primaryColor,
                        height: 3,
                        width: 33,
                      ),
                    ),
                    PriceIndex(
                      todayPrice: price,
                      yesterdayPrice: yesterdayPrice,
                    )
                  ],
                ),
                _priceInfoWidget(title: "فرق", prices: priceDifference),
                _priceInfoWidget(title: "السعر", prices: price.toString()),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget _priceInfoWidget({
  required String title,
  required String prices,
}) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(fontSize: 15, color: AppColor.primaryColor),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Container(
          color: AppColor.primaryColor,
          height: 3,
          width: 33,
        ),
      ),
      Text(
        prices,
        style: TextStyle(fontSize: 15, color: AppColor.primaryColor),
      ),
    ],
  );
}
