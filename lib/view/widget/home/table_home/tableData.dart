// ignore_for_file: file_names

import 'package:farkha_app/view/widget/home/arrow_table/arrow_down.dart';
import 'package:farkha_app/view/widget/home/arrow_table/arrow_non.dart';
import 'package:farkha_app/view/widget/home/arrow_table/arrow_up.dart';
import 'package:farkha_app/view/widget/home/table_home/text_title_data.dart';
import 'package:farkha_app/view/widget/home/table_home/text_type.dart';
import 'package:flutter/material.dart';

class TableDataHome extends StatelessWidget {
  //frakh
  final String upFrakhAbid;
  final String yUpFrakhAbid;
  final String downFrakhAbid;
  final String upFrakhBaladi;
  final String yUpFrakhBaladi;
  final String downFrakhBaladi;
  final String upFrakhSasso;
  final String yUpFrakhSasso;
  final String downFrakhSasso;
  final String upFrakhAmihatAbid;
  final String yUpFrakhAmihatAbid;
  final String downFrakhAmihatAbid;
  //bat
  final String upBatMolar;
  final String yUpBatMolar;
  final String downBatMolar;
  final String upBatFiransawi;
  final String yUpBatFiransawi;
  final String downBatFiransawi;
  final String upBatMaskufi;
  final String yUpBatMaskufi;
  final String downBatMaskufi;
  //byd
  final String upBydAbid;
  final String yUpBydAbid;
  final String downBydAbid;
  final String upBydAihmar;
  final String yUpBydAihmar;
  final String downBydAihmar;
  final String upBydBaladi;
  final String yUpBydBaladi;
  final String downBydBaladi;
  //katkit
  final String upKatkitAbid;
  final String yUpKatkitAbid;
  final String downKatkitAbid;
  final String upKatkitSasso;
  final String yUpKatkitSasso;
  final String downKatkitSasso;
  final String upKatkitBaladi;
  final String yUpKatkitBaladi;
  final String downKatkitBaladi;

  const TableDataHome({
    super.key,
    required this.upFrakhAbid,
    required this.downFrakhAbid,
    required this.upFrakhBaladi,
    required this.downFrakhBaladi,
    required this.upFrakhSasso,
    required this.downFrakhSasso,
    required this.upFrakhAmihatAbid,
    required this.downFrakhAmihatAbid,
    required this.upBatMolar,
    required this.downBatMolar,
    required this.upBatFiransawi,
    required this.downBatFiransawi,
    required this.upBatMaskufi,
    required this.downBatMaskufi,
    required this.upBydAbid,
    required this.downBydAbid,
    required this.upBydAihmar,
    required this.downBydAihmar,
    required this.upBydBaladi,
    required this.downBydBaladi,
    required this.upKatkitAbid,
    required this.downKatkitAbid,
    required this.upKatkitSasso,
    required this.downKatkitSasso,
    required this.upKatkitBaladi,
    required this.downKatkitBaladi,
    required this.yUpFrakhAbid,
    required this.yUpFrakhBaladi,
    required this.yUpFrakhSasso,
    required this.yUpFrakhAmihatAbid,
    required this.yUpBatMolar,
    required this.yUpBatFiransawi,
    required this.yUpBatMaskufi,
    required this.yUpBydAbid,
    required this.yUpBydAihmar,
    required this.yUpBydBaladi,
    required this.yUpKatkitAbid,
    required this.yUpKatkitSasso,
    required this.yUpKatkitBaladi,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          DataTable(
            columns: const  [
            DataColumn(
                label: TextDateHome(
              text: 'المؤشر',
            )),
            DataColumn(
                label: TextDateHome(
              text: 'أقل',
            )),
            DataColumn(
                label: TextDateHome(
              text: 'أعلي',
            )),
            DataColumn(
                label: TextDateHome(
              text: 'النوع',
            )),
             
          ], rows: [
            DataRow(cells: [
              DataCell(
                double.parse(upFrakhAbid) == double.parse(yUpFrakhAbid)
                    ? const ArrowNon()
                    : (double.parse(upFrakhAbid) > double.parse(yUpFrakhAbid)
                        ? const ArrowUp()
                        : const ArrowDown()),
              ),
              DataCell(Text(downFrakhAbid)),
              DataCell(Text(upFrakhAbid)),
              DataCell(TextType(type: 'فرخ ابيض')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upFrakhBaladi) == double.parse(yUpFrakhBaladi)
                  ? const ArrowNon()
                  : (double.parse(upFrakhBaladi) > double.parse(yUpFrakhBaladi)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downFrakhBaladi)),
              DataCell(Text(upFrakhBaladi)),
              DataCell(TextType(type: 'فرخ بلدي')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upFrakhSasso) == double.parse(yUpFrakhSasso)
                  ? const ArrowNon()
                  : (double.parse(upFrakhSasso) > double.parse(yUpFrakhSasso)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downFrakhSasso)),
              DataCell(Text(upFrakhSasso)),
              DataCell(TextType(type: 'فرخ ساسو')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upFrakhAmihatAbid) ==
                      double.parse(yUpFrakhAmihatAbid)
                  ? const ArrowNon()
                  : (double.parse(upFrakhAmihatAbid) >
                          double.parse(yUpFrakhAmihatAbid)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downFrakhAmihatAbid)),
              DataCell(Text(upFrakhAmihatAbid)),
              DataCell(TextType(type: 'فرخ امهات')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upKatkitAbid) == double.parse(yUpKatkitAbid)
                  ? const ArrowNon()
                  : (double.parse(upKatkitAbid) > double.parse(yUpKatkitAbid)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downKatkitAbid)),
              DataCell(Text(upKatkitAbid)),
              DataCell(TextType(type: 'كتاكيت ابيض')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upKatkitBaladi) ==
                      double.parse(yUpKatkitBaladi)
                  ? const ArrowNon()
                  : (double.parse(upKatkitBaladi) > double.parse(yUpKatkitBaladi)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downKatkitBaladi)),
              DataCell(Text(upKatkitBaladi)),
              DataCell(TextType(type: 'كتاكيت بلدي')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upKatkitSasso) == double.parse(yUpKatkitSasso)
                  ? const ArrowNon()
                  : (double.parse(upKatkitSasso) > double.parse(yUpKatkitSasso)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downKatkitSasso)),
              DataCell(Text(upKatkitSasso)),
              DataCell(TextType(type: 'كتاكيت ساسو')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upBydAihmar) == double.parse(yUpBydAihmar)
                  ? const ArrowNon()
                  : (double.parse(upBydAihmar) > double.parse(yUpBydAihmar)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downBydAihmar)),
              DataCell(Text(upBydAihmar)),
              DataCell(TextType(type: 'بيض احمر')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upBydAbid) == double.parse(yUpBydAbid)
                  ? const ArrowNon()
                  : (double.parse(upBydAbid) > double.parse(yUpBydAbid)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downBydAbid)),
              DataCell(Text(upBydAbid)),
              DataCell(TextType(type: 'بيض ابيض')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upBydBaladi) == double.parse(yUpBydBaladi)
                  ? const ArrowNon()
                  : (double.parse(upBydBaladi) > double.parse(yUpBydBaladi)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downBydBaladi)),
              DataCell(Text(upBydBaladi)),
              DataCell(TextType(type: 'بيض بلدي')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upBatMolar) == double.parse(yUpBatMolar)
                  ? const ArrowNon()
                  : (double.parse(upBatMolar) > double.parse(yUpBatMolar)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downBatMolar)),
              DataCell(Text(upBatMolar)),
              DataCell(TextType(type: 'بط مولار')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upBatMaskufi) == double.parse(yUpBatMaskufi)
                  ? const ArrowNon()
                  : (double.parse(upBatMaskufi) > double.parse(yUpBatMaskufi)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downBatMaskufi)),
              DataCell(Text(upBatMaskufi)),
              DataCell(TextType(type: 'بط مسكوفي')),
            ]),
            DataRow(cells: [
              DataCell(double.parse(upBatFiransawi) ==
                      double.parse(yUpBatFiransawi)
                  ? const ArrowNon()
                  : (double.parse(upBatFiransawi) > double.parse(yUpBatFiransawi)
                      ? const ArrowUp()
                      : const ArrowDown())),
              DataCell(Text(downBatFiransawi)),
              DataCell(Text(upBatFiransawi)),
              DataCell(TextType(type: 'بط فرنساوي')),
            ]),
          ]),
        ],
      ),
    );
  }
}
