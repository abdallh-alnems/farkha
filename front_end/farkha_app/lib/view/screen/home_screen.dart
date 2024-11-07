import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/class/handling_data.dart';
import '../../core/class/status_request.dart';
import '../../core/constant/routes/route.dart';
import '../../core/constant/theme/color.dart';
import '../../core/functions/alert_exit_app.dart';
import '../../core/functions/check_internet.dart';
import '../../core/package/rating_app.dart';
import '../../core/package/upgrade/upgrade.dart';
import '../../core/shared/custom_divider.dart';
import '../widget/view_widget/points_of_sale.dart';
import '../widget/view_widget/view_calculate.dart';
import '../../core/shared/card/big_card.dart';
import '../widget/view_widget/view_follow_up_tools.dart';
import '../widget/view_widget/view_price_and_cycle.dart';
import '../widget/prices/card_price.dart';
import '../../test2.dart';
import '../widget/ad/banner/ad_first_banner.dart';
import '../widget/ad/native/ad_home_native.dart';
import '../widget/app_bar/app_bar_home.dart';
import '../widget/cycle/card_cycle.dart';
import '../widget/home/card_price_farkh_abid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<InternetController>();

    Get.find<RateMyAppController>();

    return TapToExit(
      child: Upgrade(
        child: Scaffold(
          appBar: AppBarHome(),
          body:  SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13).r,
                child: Column(
                  children: [
                    CardPriceFarkhAbidHome(),
                    ViewPricesAndCycle(),
                    AdFirstNative(),
                    ViewCalculate(),
                    ViewHomeFollowUpTools(),
                    PointsOfSale(),
                  ],
                ),
              ),
            
          ),
          bottomNavigationBar: const AdFirstBanner(),
        ),
      ),
    );
  }
}
