import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/number_format.dart';
import '../../../core/functions/tool_page_view.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../logic/controller/tools_controller/adg_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tools/tools_button.dart';

class AverageDailyGain extends StatefulWidget {
  AverageDailyGain({super.key});
  final AdgController controller = Get.put(AdgController());

  @override
  State<AverageDailyGain> createState() => _AverageDailyGainState();
}

class _AverageDailyGainState extends State<AverageDailyGain> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    if (_formKey.currentState?.validate() != true) return;
    widget.controller.calculateADG();
  }

  Color _getAdgColor(int quality) {
    switch (quality) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.amber;
      case 3:
        return Colors.red;
      default:
        return AppColors.primaryColor;
    }
  }

  String _getAdgLabel(int quality) {
    switch (quality) {
      case 0:
        return 'ممتاز';
      case 1:
        return 'جيد';
      case 2:
        return 'مقبول';
      case 3:
        return 'يحتاج تحسين';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(
      widgetType: AverageDailyGain,
      toolName: 'متوسط النمو اليومي',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(text: 'متوسط النمو اليومي', favoriteToolName: 'متوسط النمو اليومي'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppColors.darkSurfaceElevatedColor
                          : AppColors.lightSurfaceColor,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color:
                        isDark
                            ? AppColors.darkOutlineColor.withValues(alpha: 0.5)
                            : AppColors.lightOutlineColor.withValues(
                              alpha: 0.3,
                            ),
                  ),
                  boxShadow:
                      isDark
                          ? null
                          : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TwoInputFields(
                      formKey: _formKey,
                      firstLabel: 'العمر',
                      secondLabel: 'متوسط الوزن الحالي للفرخ',
                      firstController: widget.controller.daysController,
                      secondController:
                          widget.controller.currentWeightKgController,
                      firstSuffix: 'يوم',
                      secondSuffix: 'كجم',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              ToolsButton(text: 'احسب ADG', onPressed: _onCalculatePressed),
              SizedBox(height: 14.h),
              Obx(() {
                final value = widget.controller.adg.value;
                final quality = widget.controller.getAdgQuality();
                if (value <= 0) return const SizedBox.shrink();

                final resultColor = _getAdgColor(quality);
                final label = _getAdgLabel(quality);

                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        resultColor.withValues(alpha: isDark ? 0.22 : 0.1),
                        resultColor.withValues(alpha: isDark ? 0.12 : 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: resultColor.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'متوسط الزيادة اليومية (ADG)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${formatDecimal(value, decimals: 2)} جرام/يوم',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                      if (label.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: resultColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: resultColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const NotesCard(
                notes: [
                  'بعد عمر 7 أيام يفضل حساب متوسط زيادة الوزن',
                  'ارتفاع متوسط زيادة الوزن يدل على سرعة نمو جيدة',
                  'لحساب الوزن الكلي للقطيع : اوزن 10 فراخ عشوائيًا احسب متوسط الوزن (قسمة على 10) ثم اضربه في عدد الطيور',
                ],
              ),
              const RelatedArticlesSection(relatedArticleIds: [13]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
