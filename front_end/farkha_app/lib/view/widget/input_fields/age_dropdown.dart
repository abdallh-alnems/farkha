import 'package:flutter/material.dart';

class AgeDropdown extends StatefulWidget {
  final int? selectedAge;
  final Function(int) onAgeChanged;
  final int maxAge;
  final String hint;

  const AgeDropdown({
    super.key,
    required this.selectedAge,
    required this.onAgeChanged,
    this.maxAge = 45,
    this.hint = 'اختر اليوم',
  });

  @override
  State<AgeDropdown> createState() => _AgeDropdownState();
}

class _AgeDropdownState extends State<AgeDropdown> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DropdownButtonFormField<int>(
      initialValue: widget.selectedAge,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: widget.hint,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.7)),
        ),
      ),
      dropdownColor: colorScheme.surface,
      style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      iconEnabledColor: colorScheme.onSurface,
      iconDisabledColor: colorScheme.onSurface.withOpacity(0.5),
      items:
          List.generate(widget.maxAge, (index) => index + 1).map((age) {
            return DropdownMenuItem<int>(
              value: age,
              child: Text(
                '$age يوم',
                style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
              ),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          widget.onAgeChanged(value);
          setState(() {});
        }
      },
    );
  }
}
