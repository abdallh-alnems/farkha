import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/handling_data.dart';
import '../../../logic/controller/price_controller/web_last_prices_controller.dart';
import '../../widget/web/web_bar/web_bar.dart';
import '../../widget/web/price_card.dart';

class WebBody extends StatelessWidget {
  const WebBody({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WebListPricesController());
    return Scaffold(
      appBar: WebBar(),
      body: Center(
        child: SingleChildScrollView(
          child: GetBuilder<WebListPricesController>(builder: (controller) {
            return HandlingDataView(
              statusRequest: controller.statusRequest,
              widget: Wrap(
                spacing: 70,
                runSpacing: 70,
                textDirection: TextDirection.rtl,
                children: List.generate(
                  controller.webListPricesList.length,
                  (index) {
                    final item = controller.webListPricesList[index];
                    int latestPrice = item["price"] ?? 0;
                    int secondLatestPrice = item["lastPrice"] ?? latestPrice;
                    int priceDifference = latestPrice - secondLatestPrice;
                    String differenceSign = priceDifference > 0 ? "+" : "";

                    return PriceCard(
                      title: item['type'],
                      price: latestPrice,
                      yesterdayPrice: secondLatestPrice,
                      priceDifference:
                          "$differenceSign${priceDifference.toStringAsFixed(0)}",
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
