import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../logic/controller/price_controller/last_prices_controller.dart';
import '../../widget/app/ad/banner.dart';
import '../../widget/app/ad/native.dart';
import '../../widget/app/app_bar/custom_app_bar.dart';
import '../../widget/app/prices/table/table_last_prices.dart';

class LastPrices extends StatelessWidget {
  const LastPrices({super.key});

  @override
  Widget build(BuildContext context) {
    final LastPricesController controller = Get.put(LastPricesController());
    final String mainId = Get.arguments['main_id'].toString();
    final String mainName = Get.arguments['main_name'].toString();

    controller.getDataLastPrices(mainId);

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(text: "اسعار $mainName"),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 9)
                            .r,
                    child: AdNativeWidget(adIndex: 2),
                  ),
                  TableLastPrices(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(adIndex: 2),
    );
  }
}
