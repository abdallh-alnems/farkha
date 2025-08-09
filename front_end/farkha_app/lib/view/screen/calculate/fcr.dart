import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../logic/controller/calculate_controller/fcr_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';
import '../../../core/shared/input_fields/two_input_fields.dart';
import '../../../core/shared/note_item.dart';

class Fcr extends StatefulWidget {
  Fcr({super.key});
  final FcrController controller = Get.put(FcrController());

  @override
  State<Fcr> createState() => _FcrState();
}

class _FcrState extends State<Fcr> {
  void _showBottomBarMessage(String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            child: SafeArea(
              top: false,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.97),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1500), entry.remove);
  }

  void _onCalculatePressed() {
    final feed = widget.controller.feedConsumed.value;
    final weight = widget.controller.currentWeight.value;
    if (feed <= 0 || weight <= 0) {
      _showBottomBarMessage('يرجى إدخال قيم صحيحة');
      return;
    }
    widget.controller.calculateFCR();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'FCR'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input fields row
              TwoInputFields(
                firstLabel: 'العلف المستهلك (كجم)',
                secondLabel: 'الوزن الحالي (كجم)',
                firstKeyboardType: TextInputType.number,
                secondKeyboardType: TextInputType.number,
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
              // Calculate button
              ElevatedButton(
                onPressed: _onCalculatePressed,
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
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
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
                      NoteItem('بعد عمر 21 يوما FCR يفضل حساب'),
                      NoteItem(
                        'العلف المستهلك هو التراكمي (مجموع العلف منذ البداية)',
                      ),
                      NoteItem(
                        'يفضل أن تكون الحوصلة فارغة قبل الوزن (بعد الإظلام)',
                      ),
                      NoteItem('تحسن كفاءة الإنتاج ← FCR إذا قل'),
                      NoteItem(
                        'لحساب الوزن الكلي للقطيع اوزن 10 فراخ عشوائيًا احسب متوسط الوزن (قسمة على 10) ثم اضربه في عدد الطيور',
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
}
