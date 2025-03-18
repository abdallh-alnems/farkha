import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constant/routes/route.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class AddCycle extends StatelessWidget {
  const AddCycle({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(text: "اضافة دورة"),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 55.h),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      label: 'اسم الدورة',
                      keyboardType: TextInputType.name,
                    ),
                    _buildTextField(
                      label: 'تاريخ بدء الدورة',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      label: 'نوع الدورة',
                      initialValue: 'تسمين',
                      readOnly: true,
                    ),
                    _buildTextField(
                      label: 'عمر الفراخ',
                      initialValue: '1 يوم',
                      readOnly: true,
                    ),
                    _buildTextField(
                      label: 'عدد الفراخ',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      label: 'مساحة العنبر',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      label: 'نظام التربية',
                      initialValue: 'أرضي',
                      readOnly: true,
                    ),
                    SizedBox(height: 33.h),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoute.cycle),
                        child: const Text("التالي"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
