import 'package:flutter/material.dart';

import 'input_field.dart';

class TwoInputFields extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final void Function(String) onFirstChanged;
  final void Function(String) onSecondChanged;

  const TwoInputFields({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.onFirstChanged,
    required this.onSecondChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputField(label: firstLabel, onChanged: onFirstChanged),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InputField(label: secondLabel, onChanged: onSecondChanged),
        ),
      ],
    );
  }
}
