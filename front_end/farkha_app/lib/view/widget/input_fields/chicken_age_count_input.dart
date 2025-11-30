import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'age_dropdown.dart';
import 'input_field.dart';

class ChickenAgeCountInput extends StatefulWidget {
  final TextEditingController? controller;
  final int? selectedAge;
  final Function(int) onAgeChanged;
  final int maxAge;
  final String ageHint;

  const ChickenAgeCountInput({
    super.key,
    required this.controller,
    this.selectedAge,
    required this.onAgeChanged,
    this.maxAge = 45,
    this.ageHint = 'اختر اليوم',
  });

  @override
  State<ChickenAgeCountInput> createState() => _ChickenAgeCountInputState();
}

class _ChickenAgeCountInputState extends State<ChickenAgeCountInput> {
  @override
  void didUpdateWidget(ChickenAgeCountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAge != widget.selectedAge) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _buildInputRow(),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: AgeDropdown(
            selectedAge: widget.selectedAge,
            onAgeChanged: (value) {
              widget.onAgeChanged(value);
              setState(() {}); // تحديث الواجهة
            },
            maxAge: widget.maxAge,
            hint: widget.ageHint,
          ),
        ),
        SizedBox(width: 11.w),

        Expanded(
          child: InputField(
            label: 'عدد الفراخ',
            onChanged: (value) {
              if (widget.controller != null) {
                widget.controller!.text = value;
              }
            },
          ),
        ),
      ],
    );
  }
}
