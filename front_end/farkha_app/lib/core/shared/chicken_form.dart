import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../view/widget/app/ad/native/ad_second_native.dart';
import '../functions/valid_input/validate_chick_input.dart';

class ChickenForm extends StatelessWidget {
  final TextEditingController? controller;
  final dynamic selectedAge;
  final ValueChanged<dynamic> onChanged;
  final List<DropdownMenuItem<dynamic>>? items;
  final RxBool notShowDropdownButton;
  final List<Widget> children;
  final String buttonText;
  final Function()? buttonOnPressed;
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
        padding: const EdgeInsets.symmetric(horizontal: 19).r,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5).r,
                  child: AdSecondNative(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'عدد الفراخ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          return validateChickInput(value!);
                        },
                      ),
                    ),
                    SizedBox(width: 11.h),
                    Obx(() {
                      return notShowDropdownButton.value
                          ? SizedBox.shrink()
                          : Expanded(
                              child: DropdownButtonFormField<dynamic>(
                                value: selectedAge,
                                onChanged: onChanged,
                                decoration: InputDecoration(
                                  labelText: 'اختار العمر',
                                  border: const OutlineInputBorder(),
                                ),
                                items: items,
                              ),
                            );
                    }),
                  ],
                ),
           showButton
    ? Padding(
        padding: const EdgeInsets.only(top: 17).r,
        child: ElevatedButton(
          onPressed: buttonOnPressed,
          child: Text(buttonText),
        ),
      )
    : SizedBox.shrink(),


                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
