import 'package:flutter/material.dart';
import 'input_field.dart';

class TwoInputFields extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final void Function(String) onFirstChanged;
  final void Function(String) onSecondChanged;
  final TextInputType? firstKeyboardType;
  final TextInputType? secondKeyboardType;

  const TwoInputFields({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.onFirstChanged,
    required this.onSecondChanged,
    this.firstKeyboardType,
    this.secondKeyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputField(
            label: firstLabel,
            keyboardType: firstKeyboardType,
            onChanged: onFirstChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InputField(
            label: secondLabel,
            keyboardType: secondKeyboardType,
            onChanged: onSecondChanged,
          ),
        ),
      ],
    );
  }
}
