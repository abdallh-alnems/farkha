import 'package:farkha_app/logic/controller/date_time_controller.dart';
import 'package:farkha_app/view/widget/home/arrow_table/arrow_down.dart';
import 'package:farkha_app/view/widget/home/arrow_table/arrow_non.dart';
import 'package:farkha_app/view/widget/home/arrow_table/arrow_up.dart';
import 'package:farkha_app/view/widget/home/circle_master/table_data/text_date.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableDataMasterCircle extends StatelessWidget {
  final String upPrice1;
  final String downPrice1;
  final String upPrice2;
  final String downPrice2;
  final String upPrice3;
  final String downPrice3;
  final String upPrice4;
  final String downPrice4;
  final String upPrice5;
  final String downPrice5;
  final String upPrice6;
  final String downPrice6;
  final String upPrice7;
  final String downPrice7;
  final String upPrice8;
  final String downPrice8;
  final String upPrice9;
  final String downPrice9;
  final String upPrice10;
  final String downPrice10;
  final String upPrice11;
  final String downPrice11;
  final String upPrice12;
  final String downPrice12;
  final String upPrice13;
  final String downPrice13;
  final String upPrice14;
  final String downPrice14;
  final String upPrice15;
  final String downPrice15;
  final String upPrice16;
  final String downPrice16;
  final String upPrice17;
  final String downPrice17;
  final String upPrice18;
  final String downPrice18;
  final String upPrice19;
  final String downPrice19;
  final String upPrice20;
  final String downPrice20;
  final String upPrice21;
  final String downPrice21;
  final String upPrice22;
  final String downPrice22;
  final String upPrice23;
  final String downPrice23;
  final String upPrice24;
  final String downPrice24;
  final String upPrice25;
  final String downPrice25;
  final String upPrice26;
  final String downPrice26;
  final String upPrice27;
  final String downPrice27;
  final String upPrice28;
  final String downPrice28;
  final String upPrice29;
  final String downPrice29;
  final String upPrice30;
  final String downPrice30;

  const TableDataMasterCircle({
    super.key,
    required this.upPrice1,
    required this.downPrice1,
    required this.upPrice2,
    required this.downPrice2,
    required this.upPrice3,
    required this.downPrice3,
    required this.upPrice4,
    required this.downPrice4,
    required this.upPrice5,
    required this.downPrice5,
    required this.upPrice6,
    required this.downPrice6,
    required this.upPrice7,
    required this.downPrice7,
    required this.upPrice8,
    required this.downPrice8,
    required this.upPrice9,
    required this.downPrice9,
    required this.upPrice10,
    required this.downPrice10,
    required this.upPrice11,
    required this.downPrice11,
    required this.upPrice12,
    required this.downPrice12,
    required this.upPrice13,
    required this.downPrice13,
    required this.upPrice14,
    required this.downPrice14,
    required this.upPrice15,
    required this.downPrice15,
    required this.upPrice16,
    required this.downPrice16,
    required this.upPrice17,
    required this.downPrice17,
    required this.upPrice18,
    required this.downPrice18,
    required this.upPrice19,
    required this.downPrice19,
    required this.upPrice20,
    required this.downPrice20,
    required this.upPrice21,
    required this.downPrice21,
    required this.upPrice22,
    required this.downPrice22,
    required this.upPrice23,
    required this.downPrice23,
    required this.upPrice24,
    required this.downPrice24,
    required this.upPrice25,
    required this.downPrice25,
    required this.upPrice26,
    required this.downPrice26,
    required this.upPrice27,
    required this.downPrice27,
    required this.upPrice28,
    required this.downPrice28,
    required this.upPrice29,
    required this.downPrice29,
    required this.upPrice30,
    required this.downPrice30,
  });

  @override
  Widget build(BuildContext context) {
    final date = Get.find<GetDateTime>();

    return Center(
      child: ListView(
        children: [
          DataTable(columns: const [
            DataColumn(
                label: TextDateMaster(
              text: 'المؤشر',
            )),
            DataColumn(
                label: TextDateMaster(
              text: 'أقل',
            )),
            DataColumn(
                label: TextDateMaster(
              text: 'أعلي',
            )),
            DataColumn(
                label: TextDateMaster(
              text: 'التاريخ',
            )),
          ], rows: [
            DataRow(cells: [
              DataCell(
                double.parse(upPrice1) == double.parse(upPrice2)
                    ?  const  ArrowNon()
                    : (double.parse(upPrice1) > double.parse(upPrice2)
                        ?  const ArrowUp()
                        :  const ArrowDown()),
              ),
              DataCell(Text(downPrice1)),
              DataCell(Text(upPrice1)),
              DataCell(Text(date.time1.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice2) == double.parse(upPrice3)
                  ? const ArrowNon()
                  : (double.parse(upPrice2) > double.parse(upPrice3)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice2)),
              DataCell(Text(upPrice2)),
              DataCell(Text(date.time2.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice3) == double.parse(upPrice4)
                  ? const ArrowNon()
                  : (double.parse(upPrice3) > double.parse(upPrice4)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice3)),
              DataCell(Text(upPrice3)),
              DataCell(Text(date.time3.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice4) == double.parse(upPrice5)
                  ? const ArrowNon()
                  : (double.parse(upPrice4) > double.parse(upPrice5)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice4)),
              DataCell(Text(upPrice4)),
              DataCell(Text(date.time4.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice5) == double.parse(upPrice6)
                  ? const ArrowNon()
                  : (double.parse(upPrice5) > double.parse(upPrice6)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice5)),
              DataCell(Text(upPrice5)),
              DataCell(Text(date.time5.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice6) == double.parse(upPrice7)
                  ? const ArrowNon()
                  : (double.parse(upPrice6) > double.parse(upPrice7)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice6)),
              DataCell(Text(upPrice6)),
              DataCell(Text(date.time6.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice7) == double.parse(upPrice8)
                  ? const ArrowNon()
                  : (double.parse(upPrice7) > double.parse(upPrice8)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice7)),
              DataCell(Text(upPrice7)),
              DataCell(Text(date.time7.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice8) == double.parse(upPrice9)
                  ? const ArrowNon()
                  : (double.parse(upPrice8) > double.parse(upPrice9)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice8)),
              DataCell(Text(upPrice8)),
              DataCell(Text(date.time8.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice9) == double.parse(upPrice10)
                  ? const ArrowNon()
                  : (double.parse(upPrice9) > double.parse(upPrice10)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice9)),
              DataCell(Text(upPrice9)),
              DataCell(Text(date.time9.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice10) == double.parse(upPrice11)
                  ? const ArrowNon()
                  : (double.parse(upPrice10) > double.parse(upPrice11)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice10)),
              DataCell(Text(upPrice10)),
              DataCell(Text(date.time10.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice11) == double.parse(upPrice12)
                  ? const ArrowNon()
                  : (double.parse(upPrice11) > double.parse(upPrice12)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice11)),
              DataCell(Text(upPrice11)),
              DataCell(Text(date.time11.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice12) == double.parse(upPrice13)
                  ? const ArrowNon()
                  : (double.parse(upPrice12) > double.parse(upPrice13)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice12)),
              DataCell(Text(upPrice12)),
              DataCell(Text(date.time12.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice13) == double.parse(upPrice14)
                  ? const ArrowNon()
                  : (double.parse(upPrice13) > double.parse(upPrice14)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice13)),
              DataCell(Text(upPrice13)),
              DataCell(Text(date.time13.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice14) == double.parse(upPrice15)
                  ? const ArrowNon()
                  : (double.parse(upPrice14) > double.parse(upPrice15)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice14)),
              DataCell(Text(upPrice14)),
              DataCell(Text(date.time14.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice15) == double.parse(upPrice16)
                  ? const ArrowNon()
                  : (double.parse(upPrice15) > double.parse(upPrice16)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice15)),
              DataCell(Text(upPrice15)),
              DataCell(Text(date.time15.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice16) == double.parse(upPrice17)
                  ? const ArrowNon()
                  : (double.parse(upPrice16) > double.parse(upPrice17)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice16)),
              DataCell(Text(upPrice16)),
              DataCell(Text(date.time16.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice17) == double.parse(upPrice18)
                  ? const ArrowNon()
                  : (double.parse(upPrice17) > double.parse(upPrice18)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice17)),
              DataCell(Text(upPrice17)),
              DataCell(Text(date.time17.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice18) == double.parse(upPrice19)
                  ? const ArrowNon()
                  : (double.parse(upPrice18) > double.parse(upPrice19)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice18)),
              DataCell(Text(upPrice18)),
              DataCell(Text(date.time18.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice19) == double.parse(upPrice20)
                  ? const ArrowNon()
                  : (double.parse(upPrice19) > double.parse(upPrice20)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice19)),
              DataCell(Text(upPrice19)),
              DataCell(Text(date.time19.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice20) == double.parse(upPrice21)
                  ? const ArrowNon()
                  : (double.parse(upPrice20) > double.parse(upPrice21)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice20)),
              DataCell(Text(upPrice20)),
              DataCell(Text(date.time20.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice21) == double.parse(upPrice22)
                  ? const ArrowNon()
                  : (double.parse(upPrice21) > double.parse(upPrice22)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice21)),
              DataCell(Text(upPrice21)),
              DataCell(Text(date.time21.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice22) == double.parse(upPrice23)
                  ? const ArrowNon()
                  : (double.parse(upPrice22) > double.parse(upPrice23)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice22)),
              DataCell(Text(upPrice22)),
              DataCell(Text(date.time22.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice23) == double.parse(upPrice24)
                  ? const ArrowNon()
                  : (double.parse(upPrice23) > double.parse(upPrice24)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice23)),
              DataCell(Text(upPrice23)),
              DataCell(Text(date.time23.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice24) == double.parse(upPrice25)
                  ? const ArrowNon()
                  : (double.parse(upPrice24) > double.parse(upPrice25)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice24)),
              DataCell(Text(upPrice24)),
              DataCell(Text(date.time24.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice25) == double.parse(upPrice26)
                  ? const ArrowNon()
                  : (double.parse(upPrice25) > double.parse(upPrice26)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice25)),
              DataCell(Text(upPrice25)),
              DataCell(Text(date.time25.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice26) == double.parse(upPrice27)
                  ? const ArrowNon()
                  : (double.parse(upPrice26) > double.parse(upPrice27)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice26)),
              DataCell(Text(upPrice26)),
              DataCell(Text(date.time26.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice27) == double.parse(upPrice28)
                  ? const ArrowNon()
                  : (double.parse(upPrice27) > double.parse(upPrice28)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice27)),
              DataCell(Text(upPrice27)),
              DataCell(Text(date.time27.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice28) == double.parse(upPrice29)
                  ? const ArrowNon()
                  : (double.parse(upPrice28) > double.parse(upPrice29)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice28)),
              DataCell(Text(upPrice28)),
              DataCell(Text(date.time28.value)),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upPrice29) == double.parse(upPrice30)
                  ? const ArrowNon()
                  : (double.parse(upPrice29) > double.parse(upPrice30)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downPrice29)),
              DataCell(Text(upPrice29)),
              DataCell(Text(date.time29.value)),
            ]),
            DataRow(cells: [
            const   DataCell( ArrowNon()),
              DataCell(Text(downPrice30)),
              DataCell(Text(upPrice30)),
              DataCell(Text(date.time30.value)),
            ]),
          ]),
        ],
      ),
    );
  }
}
