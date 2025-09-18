import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/functions/alert_exit_app.dart';
import '../../core/functions/check_internet.dart';
import '../../core/package/rating_app.dart';
import '../../core/package/upgrade/upgrade.dart';
import '../widget/ad/banner.dart';
import '../widget/app_bar/app_bar_home.dart';
import '../widget/home/price_stream/price_card.dart';
import '../widget/home/tools_section.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<InternetController>();
    Get.find<RateMyAppController>();

    return const Scaffold(
      appBar: AppBarHome(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TapToExit(
              child: Column(
                children: [
                  Upgrade(),
                  PriceCard(),
                  // ViewPricesAndCycle(),
                  //  AdNativeWidget(),
                  ToolsSection(),

                  //    PointsOfSale(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdBannerWidget(),
    );
  }
}
