import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../core/functions/handing_data_controller.dart';
import '../../../../data/data_source/remote/tools/articles_data.dart';
import '../../../../data/data_source/static/chicken_data.dart';

class ArticleDetailController extends GetxController {
  late StatusRequest statusRequest;
  ArticleDetailData articleDetailData = ArticleDetailData(Get.find());
  Map<String, dynamic> articleData = {};

  Future<void> getArticleDetail(String articleId) async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await articleDetailData.getArticleDetail(articleId);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      final mapResponse = response as Map<String, dynamic>;
      if (mapResponse['status'] == "success") {
        articleData = mapResponse['data'] as Map<String, dynamic>;
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  // دالة لإنشاء صفوف الجدول
  List<TableRow> getRows(
    List<int> consumptions,
    BuildContext context,
    String text,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    List<TableRow> rows = [];

    rows.add(
      TableRow(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7).r,
            child: Text(
              text,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            "العمر باليوم",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
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
                style: TextStyle(
                  fontSize: 19.sp,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              '${i + 1}',
              style: TextStyle(
                fontSize: 19.sp,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return rows;
  }

  // دالة لإرجاع الجداول حسب نوع المقال
  List<Widget> getTableWidgets(String articleId, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    List<Widget> widgets = [];

    // جدول درجات الحرارة (id = 14)
    if (int.tryParse(articleId) == 14) {
      widgets.add(
        Column(
          children: [
            const SizedBox(height: 7),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevatedColor
                    : AppColors.lightSurfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                    verticalInside: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  children: getRows(
                    temperatureList,
                    context,
                    "درجة الحرارة المئوية",
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // جدول الأوزان (id = 13)
    if (int.tryParse(articleId) == 13) {
      widgets.add(
        Column(
          children: [
            const SizedBox(height: 7),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevatedColor
                    : AppColors.lightSurfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                    verticalInside: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  children: getRows(weightsList, context, "الوزن بالجرام"),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // جدول الإضاءة (id = 9)
    if (int.tryParse(articleId) == 9) {
      widgets.add(
        Column(
          children: [
            const SizedBox(height: 7),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevatedColor
                    : AppColors.lightSurfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                    verticalInside: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  children: getRows(darknessLevels, context, "الإظلام بالساعة"),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // جدول استهلاك العلف (id = 12)
    if (int.tryParse(articleId) == 12) {
      widgets.add(
        Column(
          children: [
            const SizedBox(height: 7),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevatedColor
                    : AppColors.lightSurfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                    verticalInside: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  children: getRows(
                    feedConsumptions,
                    context,
                    "الاستهلاك بالجرام",
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return widgets;
  }
}
