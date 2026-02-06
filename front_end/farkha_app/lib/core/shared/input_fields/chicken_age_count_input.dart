import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'age_dropdown.dart';
import 'input_field.dart';

class ChickenAgeCountInput extends StatefulWidget {
  final TextEditingController? controller;
  final int? selectedAge;
  final void Function(int) onAgeChanged;
  final int maxAge;
  final String ageHint;
  final bool validateCount;
  final String? countSuffix;
  final bool useInnerForm;
  final AutovalidateMode autovalidateMode;

  const ChickenAgeCountInput({
    super.key,
    required this.controller,
    this.selectedAge,
    required this.onAgeChanged,
    this.maxAge = 45,
    this.ageHint = 'اختر اليوم',
    this.validateCount = true,
    this.countSuffix,
    this.useInnerForm = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
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
    if (!widget.useInnerForm) {
      return _buildInputRow();
    }

    return Form(
      autovalidateMode: widget.autovalidateMode,
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
            controller: widget.controller,
            suffixText: widget.countSuffix,
            onChanged: (value) {
              if (widget.controller != null) {
                widget.controller!.text = value;
              }
            },
            enableValidation: widget.validateCount,
          ),
        ),
      ],
    );
  }
}
