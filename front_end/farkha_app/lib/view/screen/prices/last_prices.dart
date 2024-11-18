import 'package:flutter/material.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/ad/native/ad_second_native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/prices/table/last_prices.dart';

class LastPrices extends StatelessWidget {
  const LastPrices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          CustomAppBar(
            text: "اسعار اليوم",
          ),
          AdSecondNative(),
          TableLastPrices(),
        ],
      ),
      bottomNavigationBar: AdSecondBanner(),
    );
  }
}
