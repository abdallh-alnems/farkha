import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/color.dart';
import '../../../data/model/last_priec/farkh_abid.dart';
import '../../../logic/controller/price_controller/last_price/farkh_abid.dart';

class CardPriceFarkhAbidHome extends StatelessWidget {
  const CardPriceFarkhAbidHome({super.key});

  @override
  Widget build(BuildContext context) {
    final lastPriceFarkhAbidController =
        Get.find<LastPriceFarkhAbidController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 13).r,
      child: Container(
        width: double.infinity,
        height: 60, // زيادة الارتفاع لعرض المحتوى بشكل أفضل
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: AppColor.secondaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(
              Icons.horizontal_rule,
              color: Colors.white,
            ),
            FutureBuilder<List<ModelLastPriceFarkhAbid>>(
              future: lastPriceFarkhAbidController.allFetchProducts(),
              builder: (context, snapshot) {
                // حالة تحميل البيانات
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: Colors.white,
                  );
                }

                // حالة وجود خطأ في جلب البيانات
                if (snapshot.hasError) {
                  return Text(
                    "حدث خطأ في جلب البيانات",
                    style: TextStyle(color: Colors.white),
                  );
                }

                // حالة وجود البيانات
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  var price = snapshot.data?[0].price;
                  return Text(
                    "$price",
                  );
                }

                // حالة عدم وجود بيانات
                return Text(
                  "لا توجد بيانات",
                );
              },
            ),
            const Text(
              "اللحم الابيض",
            ),
          ],
        ),
      ),
    );
  }
}
