import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: widget.selectedAge,
          isExpanded: true,
          alignment: Alignment.centerRight,
          dropdownColor: Colors.white,
          hint: Text(
            widget.hint,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 16),
          ),
          items:
              List.generate(widget.maxAge, (index) => index + 1).map((age) {
                return DropdownMenuItem<int>(
                  value: age,
                  child: Container(
                    width: double.infinity,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        '$age يوم',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onAgeChanged(value);
              setState(() {}); // تحديث الواجهة
            }
          },
        ),
      ),
    );
  }
}
