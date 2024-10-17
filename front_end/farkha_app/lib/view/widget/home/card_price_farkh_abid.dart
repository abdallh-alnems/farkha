import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/color.dart';
import '../../../data/model/last_priec/farkh_abid.dart';
import '../../../logic/controller/price_controller/last_price/farkh_abid.dart';

class CardPriceFarkhAbid extends StatelessWidget {
  const CardPriceFarkhAbid({super.key});

  @override
  Widget build(BuildContext context) {
    final lastPriceFarkhAbidController =
        Get.find<LastPriceFarkhAbidController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 13).r,
      child: Container(
        width: double.infinity,
        height: 31,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: AppColor.primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              Icons.horizontal_rule,
              color: Colors.white,
            ),
            FutureBuilder<List<ModelLastPriceFarkhAbid>>(
                future: lastPriceFarkhAbidController.allFetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var price = snapshot.data?[0].price;
                    return Text(
                      "$price",
                      style: TextStyle(color: Colors.white),
                    );
                  }
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.black));
                }),
            Text(
              "اللحم الابيض",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
