import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/class/handling_data.dart';
import '../../../../../logic/controller/price_controller/prices_card/prices_card_controller.dart';
import '../../price_row_item_history.dart';

class PriceContent extends StatelessWidget {
  final PricesCardController controller;

  const PriceContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return HandlingDataView(
      statusRequest: controller.statusRequest,
      widget: Obx(() {
        final selectedTypes = controller.selectedTypeIds;

        return Column(
          children:
              selectedTypes.asMap().entries.map((entry) {
                final int index = entry.key;
                final int typeId = entry.value;

                final prices = controller.getTypePrices(typeId);
                final priceDifference =
                    controller.getTypePriceDifference(typeId);

                final String typeName = controller.getTypeName(typeId);

                return Column(
                  children: [
                    if (index > 0) SizedBox(height: 4.h),
                    PriceRowItemHistory(
                      title: typeName,
                      higherPrice: prices['higher_today'] ?? '',
                      lowerPrice: prices['lower_today'] ?? '',
                      priceDifference: priceDifference,
                      typeId: typeId,
                    ),
                  ],
                );
              }).toList(),
        );
      }),
    );
  }
}
