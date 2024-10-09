import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constant/routes/route.dart';
import '../../core/constant/theme/color.dart';
import '../../core/shared/card_price.dart';
import '../../test2.dart';
import '../widget/ad/banner/ad_home_banner.dart';
import '../widget/ad/native/ad_home_native.dart';
import '../widget/app_bar/app_bar_home.dart';
import '../widget/drawer/my_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: Colors.white,

      appBar: AppBarHome(),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: double.infinity,
              color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.arrow_outward),
                  Text("55"),
                  Text("56"),
                  Text("اللحم االابيض"),
                ],
              ),
            ),
          ),
          AdHomeNative(),
          CardPrice(
            titleCard: "جميع الاسعار      ",
          ),
          CardPrice(
            titleCard: "تاريخ الاسعار     ",
          ),
          Trt(),
          Divider(
            color: Colors.black, // لون الخط
            thickness: 2, // سماكة الخط
            endIndent: 0, // المسافة من نهاية الخط
            indent: 0, // المسافة من بداية الخط
          ),
          Center(
              child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoute.test);
                  },
                  child: Text("ad"))),
          //  ElevatedButton(onPressed: (){Get.toNamed(AppRoute.adad);}, child: Text("adad"))
        ],
      ),
      bottomNavigationBar: const AdHomeBanner(),
    );
  }
}
