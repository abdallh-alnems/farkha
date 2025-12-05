import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../core/shared/price_change.dart';
import '../../../../logic/controller/price_controller/prices_by_type_controller.dart';
import 'table_header_cell.dart';

class TablePricesByType extends StatelessWidget {
  const TablePricesByType({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PricesByTypeController>(
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
      color: AppColors.primaryColor,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TableHeaderCell(text: "النوع", flex: 2),
          TableHeaderCell(text: "أعلى"),
          TableHeaderCell(text: "أقل"),
          TableHeaderCell(text: "التغير"),
        ],
      ),
    );
  }

  Widget _buildTableBody(PricesByTypeController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7).r,
      child: Column(
        children: [
          Table(
            border: const TableBorder(
              horizontalInside: BorderSide(
                color: AppColors.primaryColor,
                width: 1,
              ),
            ),
            columnWidths: const {
              0: FlexColumnWidth(2), // النوع
              1: FlexColumnWidth(1), // أعلى
              2: FlexColumnWidth(1), // أقل
              3: FlexColumnWidth(1), // التغير
            },
            children:
                controller.pricesByTypeList
                    .map((price) => _buildTableRow(price))
                    .toList(),
          ),
          const Divider(color: AppColors.primaryColor, thickness: 1),
        ],
      ),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> price) {
    // Extract data from new API structure
    final num lastHigherPrice = price["today_higher_price"] ?? 0;
    final num lastLowerPrice = price["today_lower_price"] ?? 0;
    final num yesterdayHigherPrice = price["yesterday_higher_price"] ?? 0;
    final num yesterdayLowerPrice = price["yesterday_lower_price"] ?? 0;
    final String typeName = price["type_name"] ?? "";

    // Calculate average prices for comparison
    final double currentAvgPrice = (lastHigherPrice + lastLowerPrice) / 2;
    final double yesterdayAvgPrice =
        (yesterdayHigherPrice + yesterdayLowerPrice) / 2;
    final double priceDifference = currentAvgPrice - yesterdayAvgPrice;

    return TableRow(
      children: [
        _buildTableCell(child: Center(child: Text(typeName))),
        _buildTableCell(
          child: Text(lastHigherPrice.toString(), textAlign: TextAlign.center),
        ),
        _buildTableCell(
          child: Text(lastLowerPrice.toString(), textAlign: TextAlign.center),
        ),
        _buildTableCell(
          child: Center(
            child: PriceChangeWidget(priceDifference: priceDifference),
          ),
        ),
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
