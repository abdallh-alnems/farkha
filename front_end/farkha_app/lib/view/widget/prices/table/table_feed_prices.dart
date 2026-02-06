import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/handling_data.dart';
import '../../../../core/constant/routes/route.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../core/shared/price_change.dart';
import '../../../../logic/controller/price_controller/prices_by_type_controller.dart';
import 'table_header_cell.dart';

class TableFeedPrices extends StatelessWidget {
  const TableFeedPrices({super.key});

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
          TableHeaderCell(text: 'النوع', flex: 2),
          TableHeaderCell(text: 'السعر'),
          TableHeaderCell(text: 'التغير'),
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
              horizontalInside: BorderSide(color: AppColors.primaryColor),
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
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
    final int typeId = (price['type_id'] as num?)?.toInt() ?? 0;
    final num lastPrice = (price['today_higher_price'] as num?) ?? 0;
    final num yesterdayPrice = (price['yesterday_higher_price'] as num?) ?? 0;
    final String typeName = (price['type_name'] ?? '').toString();
    final double priceDifference = (lastPrice - yesterdayPrice).toDouble();

    final VoidCallback? onTap =
        typeId > 0
            ? () {
                Get.toNamed<void>(
                  AppRoute.priceHistory,
                  arguments: {
                    'type_id': typeId,
                    'type_name': typeName,
                  },
                );
              }
            : null;

    return TableRow(
      children: [
        _buildTableCell(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Center(child: Text(typeName)),
          ),
        ),
        _buildTableCell(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              lastPrice.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        _buildTableCell(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: PriceChangeWidget(priceDifference: priceDifference),
            ),
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
