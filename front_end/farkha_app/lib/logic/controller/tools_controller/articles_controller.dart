import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ArticlesController extends GetxController {
  List<TableRow> getRows(
    List<int> consumptions,
    BuildContext context,
    String text,
  ) {
    List<TableRow> rows = [];

    rows.add(
      TableRow(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7).r,
            child: Text(
              text,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            "العمر باليوم",
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    for (int i = 0; i < consumptions.length; i++) {
      rows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7).r,
              child: Text(
                "${consumptions[i]}",
                style: TextStyle(fontSize: 19.sp),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              '${i + 1}',
              style: TextStyle(fontSize: 19.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return rows;
  }
}
