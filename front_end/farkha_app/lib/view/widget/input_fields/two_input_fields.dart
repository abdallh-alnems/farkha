import 'package:flutter/material.dart';

import 'input_field.dart';

class TwoInputFields extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final void Function(String)? onFirstChanged;
  final void Function(String)? onSecondChanged;
  final TextEditingController? firstController;
  final TextEditingController? secondController;
  final String? firstHint;
  final String? secondHint;
  final String? firstSuffix;
  final String? secondSuffix;
  final Widget? secondSuffixIcon;
  final BoxConstraints? secondSuffixIconConstraints;

  const TwoInputFields({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    this.onFirstChanged,
    this.onSecondChanged,
    this.firstController,
    this.secondController,
    this.firstHint,
    this.secondHint,
    this.firstSuffix,
    this.secondSuffix,
    this.secondSuffixIcon,
    this.secondSuffixIconConstraints,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputField(
            label: firstLabel,
            onChanged: onFirstChanged,
            controller: firstController,
            hintText: firstHint,
            suffixText: firstSuffix,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InputField(
            label: secondLabel,
            onChanged: onSecondChanged,
            controller: secondController,
            hintText: secondHint,
            suffixText: secondSuffix,
            suffixIcon: secondSuffixIcon,
            suffixIconConstraints: secondSuffixIconConstraints,
          ),
        ),
      ],
    );
  }
}
