import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../view/widget/ad/native/ad_second_native.dart';

class ChickenForm extends StatelessWidget {
  final TextEditingController? controller;
  final dynamic selectedAge;
  final ValueChanged<dynamic> onChanged;
  final List<DropdownMenuItem<dynamic>>? items;
  final RxBool notShowDropdownButton;
  final List<Widget> children;

  ChickenForm({
    super.key,
    required this.controller,
    this.selectedAge,
    this.onChanged = _defaultOnChanged,
    this.items,
    required this.children,
    RxBool? notShowDropdownButton,
  }) : notShowDropdownButton = notShowDropdownButton ?? false.obs;

  static void _defaultOnChanged(dynamic value) {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19).r,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9).r,
              child: AdSecondNative(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 13).r,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'عدد الفراخ',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Obx(() {
              return notShowDropdownButton.value
                  ? SizedBox.shrink()
                  : DropdownButtonFormField<dynamic>(
                      value: selectedAge,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        labelText: 'اختار العمر',
                        border: const OutlineInputBorder(),
                      ),
                      items: items,
                    );
            }),
            ...children
          ],
        ),
      ),
    );
  }
}
