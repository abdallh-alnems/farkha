import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/theme/color.dart';
import '../../../../core/shared/price_change.dart';
import '../../../../logic/controller/price_controller/last_prices_controller.dart';

class TableFeedPrices extends StatelessWidget {
  const TableFeedPrices({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LastPricesController>(
      builder: (controller) {
        return HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: Column(
            children: [_buildHeader(), _buildTableBody(controller)],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 33.h,
      color: AppColor.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHeaderCell("التغير"),
          _buildHeaderCell("السعر"),
          _buildHeaderCell("النوع", flex: 2),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTableBody(LastPricesController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7).r,
      child: Column(
        children: [
          Table(
            border: const TableBorder(
              horizontalInside: BorderSide(
                color: AppColor.primaryColor,
                width: 1,
              ),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
            },
            children:
                controller.lastPricesList
                    .map((price) => _buildTableRow(price))
                    .toList(),
          ),
          const Divider(color: AppColor.primaryColor, thickness: 1),
        ],
      ),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> price) {
    // Extract data from feed prices API structure
    final num lastPrice = price["today_higher_price"] ?? 0;
    final num yesterdayPrice = price["yesterday_higher_price"] ?? 0;
    final String typeName = price["type_name"] ?? "";

    // Calculate price difference
    final double priceDifference = (lastPrice - yesterdayPrice).toDouble();

    return TableRow(
      children: [
        _buildTableCell(
          child: Center(
            child: PriceChangeWidget(priceDifference: priceDifference),
          ),
        ),
        _buildTableCell(
          child: Text(lastPrice.toString(), textAlign: TextAlign.center),
        ),
        _buildTableCell(child: Center(child: Text(typeName))),
      ],
    );
  }

  Widget _buildTableCell({required Widget child}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11).r,
        child: child,
      ),
    );
  }
}
