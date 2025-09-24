import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../logic/controller/tools_controller/fcr_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../widget/tools/notes_card.dart';
import '../../widget/tools/tools_button.dart';

class Fcr extends StatefulWidget {
  Fcr({super.key});
  final FcrController controller = Get.put(FcrController());

  @override
  State<Fcr> createState() => _FcrState();
}

class _FcrState extends State<Fcr> {
  final _formKey = GlobalKey<FormState>();

  void _onCalculatePressed() {
    widget.controller.calculateFCR(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'FCR', toolKey: 'fcrDialog'),
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
                  firstLabel: 'العلف المستهلك (كجم)',
                  secondLabel: 'الوزن الحالي (كجم)',
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
                  return value > 0
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '(FCR) معامل التحويل',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            value.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                      : const SizedBox.shrink();
                }),
                const NotesCard(
                  notes: [
                    'FCR = العلف المستهلك ÷ الوزن المكتسب',
                    'FCR أقل من 1.5 يعتبر ممتاز',
                    'FCR من 1.5 إلى 1.8 يعتبر جيد',
                    'FCR أكثر من 1.8 يحتاج تحسين',
                    'يتم حساب FCR في نهاية دورة التربية',
                  ],
                ),
                const SizedBox(height: 16),
                // Good/Bad ranges
                const Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '📈 النسب الجيدة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('1.4 – 1.6 (ممتاز)', textAlign: TextAlign.right),
                      Text('1.6 – 1.8 (جيد)', textAlign: TextAlign.right),
                      SizedBox(height: 8),
                      Text(
                        '📉 النسب غير الجيدة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('> 1.9 (ضعيف)', textAlign: TextAlign.right),
                    ],
                  ),
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
