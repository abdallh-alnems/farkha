import 'package:flutter/material.dart';

class AgeDropdown extends StatelessWidget {
  final int? selectedAge; 
  final ValueChanged<int?> onChanged; 

  const AgeDropdown({
    super.key,
    required this.selectedAge,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedAge,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'اختار العمر',
        border: const OutlineInputBorder(),
      ),
      items: List.generate(45, (index) => index + 1).map((age) {
        return DropdownMenuItem<int>(
          value: age,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('$age يوم'),
          ),
        );
      }).toList(),
    );
  }
}
