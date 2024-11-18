import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/theme/color.dart';
import '../../../../core/shared/price_index.dart';
import '../../../../logic/controller/price_controller/last_prices_controller.dart';

class TableLastPrices extends StatelessWidget {
  const TableLastPrices({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LastPricesController>(
      init: LastPricesController(),
      builder: (controller) {
        return HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: Expanded(
            child: Column(
              children: [
                Container(
                  height: 33.h,
                  color: AppColor.primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            "المؤشر",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            "فرق",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            "السعر",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(right: 41).r,
                          child: Text(
                            "النوع",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7).r,
                      child: Table(
                        border: const TableBorder(
                          horizontalInside:
                              BorderSide(color: Colors.grey, width: 1),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(2),
                        },
                        children: [
                          ...controller.pricesList.map((price) {
                            int latestPrice = price.latestPrice ?? 0;
                            int secondLatestPrice =
                                price.secondLatestPrice ?? latestPrice;

                            int priceDifference =
                                latestPrice - secondLatestPrice;
                            String differenceSign =
                                priceDifference > 0 ? "+" : "";

                            return TableRow(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 11)
                                          .r,
                                  child: PriceIndex(
                                    todayPrice: latestPrice,
                                    yesterdayPrice: secondLatestPrice,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 11)
                                          .r,
                                  child: Text(
                                    "$differenceSign${priceDifference.toStringAsFixed(0)}",
                                    style: TextStyle(
                                        color: priceDifference > 0
                                            ? Colors.red
                                            : Colors.green),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 11)
                                          .r,
                                  child: Text(
                                    latestPrice.toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                          top: 11, bottom: 11, right: 15)
                                      .r,
                                  child: Text(
                                    price.typeName ?? "غير محدد",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
