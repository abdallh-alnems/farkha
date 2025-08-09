import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final String label;
  final void Function(String) onChanged;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    required this.label,
    required this.onChanged,
    this.keyboardType,
  });

  String _formatNumber(String value) {
    // إزالة جميع الأحرف غير الرقمية
    String numbersOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (numbersOnly.isEmpty) return '';

    // تحويل إلى رقم وتنسيقه
    int? number = int.tryParse(numbersOnly);
    if (number == null) return '';

    // تنسيق الرقم مع فواصل الآلاف
    String formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        inputFormatters:
            keyboardType == TextInputType.number
                ? [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String formatted = _formatNumber(newValue.text);
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }),
                ]
                : null,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
        ),
        onChanged: (value) {
          // إزالة الفواصل قبل إرسال القيمة
          String cleanValue = value.replaceAll(',', '');
          onChanged(cleanValue);
        },
      ),
    );
  }
}
