import 'package:flutter/material.dart';

import '../../functions/input_validation.dart';

class InputField extends StatelessWidget {
  final String label;
  final void Function(String) onChanged;

  const InputField({super.key, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        textAlign: TextAlign.right,
        keyboardType: TextInputType.number,
        validator: InputValidation.validateAndFormatNumber,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
