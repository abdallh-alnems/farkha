import 'package:flutter/material.dart';
import 'input_field.dart';

class ThreeInputFields extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final String thirdLabel;
  final void Function(String) onFirstChanged;
  final void Function(String) onSecondChanged;
  final void Function(String) onThirdChanged;
  final TextInputType? firstKeyboardType;
  final TextInputType? secondKeyboardType;
  final TextInputType? thirdKeyboardType;

  const ThreeInputFields({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.thirdLabel,
    required this.onFirstChanged,
    required this.onSecondChanged,
    required this.onThirdChanged,
    this.firstKeyboardType,
    this.secondKeyboardType,
    this.thirdKeyboardType,
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
        const SizedBox(width: 12),
        Expanded(
          child: InputField(
            label: secondLabel,
            keyboardType: secondKeyboardType,
            onChanged: onSecondChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InputField(
            label: thirdLabel,
            keyboardType: thirdKeyboardType,
            onChanged: onThirdChanged,
          ),
        ),
      ],
    );
  }
}
