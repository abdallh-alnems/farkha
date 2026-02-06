import 'package:flutter/material.dart';

import 'input_field.dart';

class ThreeInputFields extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final String thirdLabel;
  final void Function(String)? onFirstChanged;
  final void Function(String)? onSecondChanged;
  final void Function(String)? onThirdChanged;
  final TextEditingController? firstController;
  final TextEditingController? secondController;
  final TextEditingController? thirdController;
  final String? firstHint;
  final String? secondHint;
  final String? thirdHint;
  final String? firstSuffix;
  final String? secondSuffix;
  final String? thirdSuffix;
  final GlobalKey<FormState>? formKey;
  final bool firstAllowZero;
  final bool secondAllowZero;
  final bool thirdAllowZero;

  const ThreeInputFields({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.thirdLabel,
    this.onFirstChanged,
    this.onSecondChanged,
    this.onThirdChanged,
    this.firstController,
    this.secondController,
    this.thirdController,
    this.firstHint,
    this.secondHint,
    this.thirdHint,
    this.firstSuffix,
    this.secondSuffix,
    this.thirdSuffix,
    this.formKey,
    this.firstAllowZero = false,
    this.secondAllowZero = false,
    this.thirdAllowZero = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InputField(
                label: firstLabel,
                onChanged: onFirstChanged,
                controller: firstController,
                hintText: firstHint,
                suffixText: firstSuffix,
                allowZero: firstAllowZero,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputField(
                label: secondLabel,
                onChanged: onSecondChanged,
                controller: secondController,
                hintText: secondHint,
                suffixText: secondSuffix,
                allowZero: secondAllowZero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InputField(
          label: thirdLabel,
          onChanged: onThirdChanged,
          controller: thirdController,
          hintText: thirdHint,
          suffixText: thirdSuffix,
          allowZero: thirdAllowZero,
        ),
      ],
    );
    if (formKey != null) {
      return Form(key: formKey, child: content);
    }
    return content;
  }
}
