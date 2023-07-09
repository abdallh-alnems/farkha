import 'package:farkha_app/view/widget/home/circle_master/table_data/text_date.dart';
import 'package:flutter/material.dart';

class A3lafTableDataMaster extends StatelessWidget {
  final String upPrice1;
  final String upPrice2;
  final String upPrice3;
  final String upPrice4;
  final String upPrice5;
  final String upPrice6;
  final String upPrice7;
  final String upPrice8;

  const A3lafTableDataMaster({
    super.key,
    required this.upPrice1,
    required this.upPrice2,
    required this.upPrice3,
    required this.upPrice4,
    required this.upPrice5,
    required this.upPrice6,
    required this.upPrice7,
    required this.upPrice8,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          DataTable(columns: const [
            DataColumn(
              label: TextDateMaster(
                text: '        السعر',
              ),
            ),
            DataColumn(
              label: TextDateMaster(
                text: '                 النوع',
              ),
            ),
          ], rows: [
            DataRow(cells: [
              DataCell(Text("          $upPrice1")),
             const DataCell( Text('                         بادي')),
            ]),
            DataRow(cells: [
              DataCell(Text("          $upPrice2")),
             const DataCell(Text('                        نامي')),
            ]),
            DataRow(cells: [
              DataCell(Text("          $upPrice3")),
           const   DataCell(Text('                        ناهي')),
            ]),
            DataRow(cells: [
              DataCell(Text("          $upPrice4")),
           const   DataCell(Text('                   بياض %14')),
            ]),
            DataRow(cells: [
              DataCell(Text("          $upPrice5")),
             const DataCell(Text('                   بياض %16')),
            ]),
            DataRow(cells: [
              DataCell(Text("          $upPrice6")),
             const DataCell(Text('                   بياض %17')),
            ]),
            DataRow(cells: [
              DataCell(Text("          $upPrice7")),
             const DataCell(Text('                   بياض %18')),
            ]),
            DataRow(cells: [
              DataCell(Text("          $upPrice8")),
             const DataCell(Text('                   بياض %19')),
            ]),
          ]),
        ],
      ),
    );
  }
}
