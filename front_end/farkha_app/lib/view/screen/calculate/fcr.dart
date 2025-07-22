import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controller/calculate_controller/fcr_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class Fcr extends StatelessWidget {
  Fcr({super.key});
  final FcrController controller = Get.put(FcrController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              CustomAppBar(text: 'FCR'),
              const SizedBox(height: 20),

              // Input fields row
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'العلف المستهلك (كجم)',
                      onChanged:
                          (value) =>
                              controller.feedConsumed.value =
                                  double.tryParse(value) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      label: 'الوزن الحالي (كجم)',
                      onChanged:
                          (value) =>
                              controller.currentWeight.value =
                                  double.tryParse(value) ?? 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calculate button
              ElevatedButton(
                onPressed: controller.calculateFCR,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('احسب الآن', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),

              // Result display
              Obx(() {
                final value = controller.fcr.value;
                return value > 0
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'معامل التحويل (FCR)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          value.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    )
                    : const SizedBox.shrink();
              }),
              const SizedBox(height: 32),

              // Notes section
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '📌 ملاحظات هامة',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 12),
                      _buildNote('يُفضل حساب FCR بعد عمر 21 يومًا.'),
                      _buildNote(
                        'العلف المستهلك هو التراكمي (مجموع العلف منذ البداية).',
                      ),
                      _buildNote(
                        'يفضل أن تكون الحوصلة فارغة قبل الوزن (بعد الإظلام).',
                      ),
                      _buildNote('إذا قلّ FCR → تحسن كفاءة الإنتاج.'),
                      _buildNote(
                        'لحساب الوزن الكلي للقطيع: وزّن 10 فراخ عشوائيًا، احسب متوسط الوزن (قسمة على 10)، ثم اضربه في عدد الطيور.',
                      ),
                      const SizedBox(height: 16),

                      // Good/Bad ranges
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text(
                              '📈 النسب الجيدة',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '1.4 – 1.6 (ممتاز)',
                              textAlign: TextAlign.right,
                            ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required void Function(String) onChanged,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildNote(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
        ],
      ),
    );
  }
}
