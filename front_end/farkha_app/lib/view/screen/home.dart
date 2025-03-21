import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/functions/alert_exit_app.dart';
import '../../core/functions/check_internet.dart';
import '../../core/package/rating_app.dart';
import '../../core/package/upgrade/upgrade.dart';
import '../widget/view_widget/points_of_sale.dart';
import '../widget/view_widget/view_calculate.dart';
import '../widget/view_widget/view_follow_up_tools.dart';
import '../widget/view_widget/view_price_and_cycle.dart';
import '../widget/ad/banner.dart';
import '../widget/ad/native.dart';
import '../widget/app_bar/app_bar_home.dart';
import '../widget/prices/card_price_farkh_abid.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<InternetController>();
    Get.find<RateMyAppController>();

    return Scaffold(
      appBar: const AppBarHome(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13).r,
          child: const TapToExit(
            child: Column(
              children: [
                Upgrade(),
                CardPriceFarkhAbidHome(),
                ViewPricesAndCycle(),
                AdNativeWidget(adIndex: 0),
                ViewCalculate(),
                ViewHomeFollowUpTools(),
                PointsOfSale(),
                
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(adIndex: 0),
    );
  }
}
