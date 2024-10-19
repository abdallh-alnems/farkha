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
import '../widget/cycle/dashboard.dart';
import '../widget/drawer/my_drawer.dart';
import '../widget/home/card_price_farkh_abid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBarHome(),
      drawer: MyDrawer(),
      body: Column(
        children: [
         CardPriceFarkhAbid(),
          AdHomeNative(),

         Dashboard(),
         
        ],
      ),
      bottomNavigationBar: const AdHomeBanner(),
    );
  }
}
