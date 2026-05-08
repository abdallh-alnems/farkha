import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/price_controller/prices_by_type_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/prices/table/table_feed_prices.dart';
import '../../widget/prices/table/table_prices_by_type.dart';

class PricesByType extends StatelessWidget {
  const PricesByType({super.key});

  @override
  Widget build(BuildContext context) {
    final String mainId = Get.arguments['main_id'].toString();
    final String mainName = Get.arguments['main_name'].toString();
    final bool isFeedPrices = mainId == '6' || mainId == '7';

    final PricesByTypeController controller = Get.put(PricesByTypeController());
    controller.getDataPricesByType(mainId);

    return Scaffold(
      appBar: CustomAppBar(text: 'اسعار $mainName'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenH,
                      vertical: AppSpacing.sm,
                    ),
                    child: const AdNativeWidget(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenH,
                    ),
                    child: isFeedPrices
                        ? const TableFeedPrices()
                        : const TablePricesByType(),
                  ),
                  SizedBox(height: AppSpacing.lg),
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
