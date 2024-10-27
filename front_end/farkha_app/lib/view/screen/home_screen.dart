import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constant/routes/route.dart';
import '../../core/constant/theme/color.dart';
import '../../core/functions/alert_exit_app.dart';
import '../../core/shared/general_card.dart';
import '../widget/prices/card_price.dart';
import '../../test2.dart';
import '../widget/ad/banner/ad_home_banner.dart';
import '../widget/ad/native/ad_home_native.dart';
import '../widget/app_bar/app_bar_home.dart';
import '../widget/cycle/card_cycle.dart';
import '../widget/drawer/my_drawer.dart';
import '../widget/home/card_price_farkh_abid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TapToExit(
      child: Scaffold(
        appBar: AppBarHome(),
        drawer: MyDrawer(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13).r,
          child: Column(
            children: [
              CardPriceFarkhAbidHome(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15).r,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CardPrice(),
                    CardCycle(),
                  ],
                ),
              ),
              AdHomeNative(),
              GeneralCard(),
            ],
          ),
        ),
        bottomNavigationBar: const AdHomeBanner(),
      ),
    );
  }
}
