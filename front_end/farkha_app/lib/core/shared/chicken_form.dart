import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../view/widget/app/ad/native.dart';
import '../functions/valid_input/validate_chick_input.dart';

class ChickenForm extends StatelessWidget {
  final TextEditingController? controller;
  final dynamic selectedAge;
  final ValueChanged<dynamic> onChanged;
  final List<DropdownMenuItem<dynamic>>? items;
  final RxBool notShowDropdownButton;
  final List<Widget> children;
  final String buttonText;
  final VoidCallback? buttonOnPressed;
  final bool showButton;

  ChickenForm({
    super.key,
    required this.controller,
    this.selectedAge,
    this.onChanged = _defaultOnChanged,
    this.items,
    required this.children,
    RxBool? notShowDropdownButton,
    this.buttonText = "",
    this.buttonOnPressed,
    this.showButton = false,
  }) : notShowDropdownButton = notShowDropdownButton ?? false.obs;

  static void _defaultOnChanged(dynamic value) {}

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 19.w),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  _buildAdWidget(),
                  _buildInputRow(),
                  if (showButton) _buildSubmitButton(),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ويدجت الإعلان
  Widget _buildAdWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: AdNativeWidget(adIndex: 1),
    );
  }

  /// ويدجت حقل الإدخال والقائمة المنسدلة
  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'عدد الفراخ',
              border: OutlineInputBorder(),
            ),
            validator: (value) => validateChickInput(value ?? ""),
          ),
        ),
        SizedBox(width: 11.w),
        Obx(() => notShowDropdownButton.value
            ? const SizedBox.shrink()
            : _buildDropdown()),
      ],
    );
  }

  /// ويدجت القائمة المنسدلة
  Widget _buildDropdown() {
    return Expanded(
      child: DropdownButtonFormField<dynamic>(
        value: selectedAge,
        onChanged: onChanged,
        decoration: const InputDecoration(
          labelText: 'اختار العمر',
          border: OutlineInputBorder(),
        ),
        items: items,
      ),
    );
  }

  /// ويدجت زر الإرسال
  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.only(top: 17.h),
      child: ElevatedButton(
        onPressed: buttonOnPressed,
        child: Text(buttonText),
      ),
    );
  }
}
