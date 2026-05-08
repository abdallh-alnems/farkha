import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/theme/theme.dart';
import '../../../../core/functions/handling_data_controller.dart';
import '../../../../data/data_source/remote/tools/articles_data.dart';
import '../../../../data/data_source/static/chicken_data.dart';

class ArticleDetailController extends GetxController {
  late StatusRequest statusRequest;
  ArticleDetailData articleDetailData = ArticleDetailData(Get.find());
  Map<String, dynamic> articleData = {};

  Future<void> getArticleDetail(String articleId) async {
    statusRequest = StatusRequest.loading;
    update();
    final response = await articleDetailData.getArticleDetail(articleId);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      final mapResponse = response as Map<String, dynamic>;
      if (mapResponse['status'] == 'success') {
        articleData = mapResponse['data'] as Map<String, dynamic>;
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  List<TableRow> getRows(
    List<int> consumptions,
    BuildContext context,
    String headerLeft,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<TableRow> rows = [];

    rows.add(
      TableRow(
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
            child: Text(
              headerLeft,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
            child: Text(
              'العمر باليوم',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );

    for (int i = 0; i < consumptions.length; i++) {
      final isEven = i.isEven;
      rows.add(
        TableRow(
          decoration: BoxDecoration(
            color: isEven
                ? colorScheme.surface
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              child: Text(
                '${consumptions[i]}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    return rows;
  }

  List<Widget> getTableWidgets(String articleId, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> widgets = [];

    final tableConfigs = <int, (List<int>, String)>{
      14: (temperatureList, 'درجة الحرارة المئوية'),
      13: (weightsList, 'الوزن بالجرام'),
      9: (darknessLevels, 'الإظلام بالساعة'),
      12: (feedConsumptions, 'الاستهلاك بالجرام'),
    };

    final id = int.tryParse(articleId);
    if (id != null && tableConfigs.containsKey(id)) {
      final (data, header) = tableConfigs[id]!;
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevatedColor
                  : AppColors.lightSurfaceColor,
              borderRadius: AppDimens.borderMd,
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.12),
                ),
                verticalInside: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.12),
                ),
              ),
              children: getRows(data, context, header),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
