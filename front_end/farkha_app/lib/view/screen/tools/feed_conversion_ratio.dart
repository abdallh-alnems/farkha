import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/tools_controller/feed_conversion_ratio_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/input_fields/two_input_fields.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/tools_button.dart';

class FeedConversionRatio extends StatefulWidget {
  FeedConversionRatio({super.key});
  final FcrController controller = Get.put(FcrController());

  @override
  State<FeedConversionRatio> createState() => _FeedConversionRatioState();
}

class _FeedConversionRatioState extends State<FeedConversionRatio> {
  final _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    widget.controller.calculateFCR(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'معامل التحويل الغذائي'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input fields row
                TwoInputFields(
                  firstLabel: 'العلف المستهلك',
                  secondLabel: 'الوزن الحالي',
                  onFirstChanged:
                      (value) =>
                          widget.controller.feedConsumed.value =
                              double.tryParse(value) ?? 0,
                  onSecondChanged:
                      (value) =>
                          widget.controller.currentWeight.value =
                              double.tryParse(value) ?? 0,
                ),
                const SizedBox(height: 24),
                const AdNativeWidget(),
                const SizedBox(height: 24),
                ToolsButton(text: 'احسب الآن', onPressed: _onCalculatePressed),
                const SizedBox(height: 24),
                // Result display
                Obx(() {
                  final value = widget.controller.fcr.value;
                  final colorScheme = Theme.of(context).colorScheme;
                  return value > 0
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'معامل التحويل (FCR)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            value.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      )
                      : const SizedBox.shrink();
                }),
                const NotesCard(
                  notes: [
                    'معامل التحويل = العلف المستهلك ÷ الوزن المكتسب',
                    'معامل التحويل أقل من 1.5 يعتبر ممتاز',
                    'معامل التحويل من 1.5 إلى 1.8 يعتبر جيد',
                    'معامل التحويل أكثر من 1.8 يحتاج تحسين',
                    'يتم حساب معامل التحويل في نهاية دورة التربية',
                  ],
                ),
                const SizedBox(height: 16),
                // Good/Bad ranges
                Builder(
                  builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;

                    return Card(
                      color:
                          isDark
                              ? AppColors.darkSurfaceElevatedColor
                              : AppColors.lightSurfaceColor,
                      elevation: isDark ? 0 : 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                              isDark
                                  ? AppColors.darkOutlineColor.withValues(
                                    alpha: 0.5,
                                  )
                                  : AppColors.lightOutlineColor.withValues(
                                    alpha: 0.3,
                                  ),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📈 النسب الجيدة',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  '1.4 – 1.6 (ممتاز)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  '1.6 – 1.8 (جيد)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '📉 النسب غير الجيدة',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  '> 1.9 (ضعيف)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
