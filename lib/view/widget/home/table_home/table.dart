import 'package:farkha_app/view/widget/home/arrow_table/arrow_down.dart';
import 'package:farkha_app/view/widget/home/arrow_table/arrow_non.dart';
import 'package:farkha_app/view/widget/home/arrow_table/arrow_up.dart';
import 'package:farkha_app/view/widget/home/table_home/text_data.dart';
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
    return ListView(
      children: [
        DataTable(columns: [
          DataColumn(
              label: TextDateHome(
            text: 'المؤشر',
          )),
          DataColumn(
              label: TextDateHome(
            text: 'اقل',
          )),
          DataColumn(
              label: TextDateHome(
            text: 'اعلي',
          )),
          DataColumn(
              label: TextDateHome(
            text: 'النوع',
          )),
        ], rows: [
          DataRow(cells: [
            DataCell(
              double.parse(upFrakhAbid) == double.parse(yUpFrakhAbid)
                  ? ArrowNon()
                  : (double.parse(upFrakhAbid) > double.parse(yUpFrakhAbid)
                      ? ArrowUp()
                      : ArrowDown()),
            ),
            DataCell(Text(downFrakhAbid)),
            DataCell(Text(upFrakhAbid)),
             DataCell(Text('فراخ بيضاء')),
          ]),
          DataRow(cells: [
            DataCell(double.parse(upFrakhBaladi) == double.parse(yUpFrakhBaladi)
                ? ArrowNon()
                : (double.parse(upFrakhBaladi) > double.parse(yUpFrakhBaladi)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downFrakhBaladi)),
            DataCell(Text(upFrakhBaladi)),
            DataCell(Text('فراخ بيضاء')),
          ]),
          DataRow(cells: [
            DataCell(double.parse(upFrakhSasso) == double.parse(yUpFrakhSasso)
                ? ArrowNon()
                : (double.parse(upFrakhSasso) > double.parse(yUpFrakhSasso)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downFrakhSasso)),
            DataCell(Text(upFrakhSasso)),
           DataCell(Text('فراخ بيضاء')),
          ]),
          DataRow(cells: [
            DataCell(double.parse(upFrakhAmihatAbid) == double.parse(yUpFrakhAmihatAbid)
                ? ArrowNon()
                : (double.parse(upFrakhAmihatAbid) > double.parse(yUpFrakhAmihatAbid)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downFrakhAmihatAbid)),
            DataCell(Text(upFrakhAmihatAbid)),
             DataCell(Text('فراخ بيضاء')),
          ]),
          DataRow(cells: [
            DataCell(double.parse(upKatkitAbid) == double.parse(yUpKatkitAbid)
                ? ArrowNon()
                : (double.parse(upKatkitAbid) > double.parse(yUpKatkitAbid)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downKatkitAbid)),
            DataCell(Text(upKatkitAbid)),
             DataCell(Text('فراخ بيضاء')),
          ]),
            DataRow(cells: [
            DataCell(double.parse(upKatkitBaladi) == double.parse(yUpKatkitBaladi)
                ? ArrowNon()
                : (double.parse(upKatkitBaladi) > double.parse(yUpKatkitBaladi)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downKatkitBaladi)),
            DataCell(Text(upKatkitBaladi)),
           DataCell(Text('فراخ بيضاء')),
          ]),
          DataRow(cells: [
            DataCell(double.parse(upKatkitSasso) == double.parse(yUpKatkitSasso)
                ? ArrowNon()
                : (double.parse(upKatkitSasso) > double.parse(yUpKatkitSasso)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downKatkitSasso)),
            DataCell(Text(upKatkitSasso)),
          DataCell(Text('فراخ بيضاء')),
          ]),
        
          DataRow(cells: [
            DataCell(double.parse(upBydAihmar) == double.parse(yUpBydAihmar)
                ? ArrowNon()
                : (double.parse(upBydAihmar) > double.parse(yUpBydAihmar)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downBydAihmar)),
            DataCell(Text(upBydAihmar)),
            DataCell(Text('فراخ بيضاء')),
          ]),
          DataRow(cells: [
            DataCell(double.parse(upBydAbid) == double.parse(yUpBydAbid)
                ? ArrowNon()
                : (double.parse(upBydAbid) > double.parse(yUpBydAbid)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downBydAbid)),
            DataCell(Text(upBydAbid)),
            DataCell(Text('فراخ بيضاء')),
          ]),
          DataRow(cells: [
            DataCell(double.parse(upKatkitBaladi) == double.parse(yUpKatkitBaladi)
                ? ArrowNon()
                : (double.parse(upKatkitBaladi) > double.parse(yUpKatkitBaladi)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downKatkitBaladi)),
            DataCell(Text(upKatkitBaladi)),
             DataCell(Text('فراخ بيضاء')),
          ]),
          DataRow(cells: [
            DataCell(double.parse(upBatMolar) == double.parse(yUpBatMolar)
                ? ArrowNon()
                : (double.parse(upBatMolar) > double.parse(yUpBatMolar)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downBatMolar)),
            DataCell(Text(upBatMolar)),
             DataCell(Text('فراخ بيضاء')),
          ]),
          DataRow(cells: [
            DataCell(double.parse(upBatMaskufi) == double.parse(yUpBatMaskufi)
                ? ArrowNon()
                : (double.parse(upBatMaskufi) > double.parse(yUpBatMaskufi)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(downBatMaskufi)),
            DataCell(Text(upBatMaskufi)),
            DataCell(Text('فراخ بيضاء')),
          ]),
          DataRow(cells: [
            DataCell(double.parse(upBatFiransawi) == double.parse(yUpBatFiransawi)
                ? ArrowNon()
                : (double.parse(upBatFiransawi) > double.parse(yUpBatFiransawi)
                    ? ArrowUp()
                    : ArrowDown())),
            DataCell(Text(upBatFiransawi)),
            DataCell(Text(upBatFiransawi)),
            DataCell(Text('فراخ بيضاء')),
          ]),
         
        ]),
      ],
    );
  }
}
