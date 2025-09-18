import 'package:flutter/material.dart';

import 'input_field.dart';

class ThreeInputFields extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final String thirdLabel;
  final void Function(String) onFirstChanged;
  final void Function(String) onSecondChanged;
  final void Function(String) onThirdChanged;

  const ThreeInputFields({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.thirdLabel,
    required this.onFirstChanged,
    required this.onSecondChanged,
    required this.onThirdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InputField(label: firstLabel, onChanged: onFirstChanged),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputField(label: secondLabel, onChanged: onSecondChanged),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InputField(label: thirdLabel, onChanged: onThirdChanged),
      ],
    );
  }
}
