import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../logic/controller/price_controller/prices_by_type_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/prices/table/table_feed_prices.dart';
import '../../widget/prices/table/table_prices_by_type.dart';

class PricesByType extends StatelessWidget {
  const PricesByType({super.key});

  @override
  Widget build(BuildContext context) {
    final String mainId = Get.arguments['main_id'].toString();
    final String mainName = Get.arguments['main_name'].toString();

    // Check if this is a feed prices request (ID 6 or 7)
    final bool isFeedPrices = mainId == '6' || mainId == '7';

   final PricesByTypeController controller = Get.put(PricesByTypeController());
    controller.getDataPricesByType(mainId);
    return Scaffold(
      appBar: CustomAppBar(text: "اسعار $mainName"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 9,
                        ).r,  
                    child: const AdNativeWidget(),
                  ),
                  isFeedPrices
                      ? const TableFeedPrices()
                      : const TablePricesByType(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
