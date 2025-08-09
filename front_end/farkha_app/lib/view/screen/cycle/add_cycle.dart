// lib/views/screens/add_cycle.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/color.dart';
import '../../../core/functions/valid_input/validate_chick_input.dart';
import '../../../logic/controller/cycle_controller.dart';

class AddCycle extends StatelessWidget {
  AddCycle({super.key});
  final CycleController controller = Get.find<CycleController>();
  bool get fromHome => Get.arguments?['fromHome'] == true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primaryColor, Colors.deepPurple.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [_buildHeader(), Expanded(child: _buildForm())],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 31.h),
      child: Stack(
        children: [
          Obx(() {
            if (!controller.isEdit.value && fromHome) {
              return Padding(
                padding: const EdgeInsets.only(right: 11),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 81.w,
                    height: 23.w,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "صلاحيات",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.manage_accounts,
                          color: Colors.white,
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          }),

          Align(
            alignment: Alignment.center,
            child: Obx(
              () => Text(
                controller.isEdit.value ? 'تعديل الدورة' : 'إضافة دورة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 23),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: Colors.white, size: 25.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
      padding: EdgeInsets.symmetric(vertical: 41.h, horizontal: 19.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حقل اسم الدورة مع التحقق من التكرار
              Padding(
                padding: EdgeInsets.only(bottom: 21.h),
                child: TextFormField(
                  controller: controller.nameController,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.isEmpty) {
                      return 'يرجى إدخال اسم الدورة';
                    }
                    final duplicate = controller.cycles.indexWhere(
                      (c) => c['name'] == name,
                    );
                    if (duplicate != -1) {
                      if (controller.isEdit.value &&
                          controller.editIndex.value == duplicate) {
                        return null;
                      }
                      return 'يوجد دورة بنفس الاسم';
                    }
                    return null;
                  },
                  decoration: _inputDecoration('اسم الدورة'),
                ),
              ),
              _buildFixedField(label: 'نوع الدورة', value: 'تسمين'),
              // حقل عدد الفراخ مع وحدة 'فرخ'
              _buildTextField(
                label: 'عدد الفراخ',
                controller: controller.countController,
                keyboardType: TextInputType.number,
                validator: validateChickInput,
                suffix: ' فرخ',
              ),
              // حقل مساحة العنبر مع وحدة 'متر مربع'
              _buildTextField(
                label: 'مساحة العنبر',
                controller: controller.spaceController,
                keyboardType: TextInputType.number,
                suffix: 'م2',
              ),
              _buildFixedField(label: 'نظام التربية', value: 'أرضي'),
              _buildDateField(),
              SizedBox(height: 25.h),
              Center(
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColor.primaryColor,
                        Colors.deepPurple.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_downward_rounded,
                      size: 28.sp,
                      color: Colors.white,
                    ),
                    onPressed: () => controller.onNext(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? suffix,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 21.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            validator ??
            (value) =>
                value == null || value.isEmpty ? 'يرجى إدخال $label' : null,
        decoration: _inputDecoration(label).copyWith(suffixText: suffix),
      ),
    );
  }

  Widget _buildFixedField({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 21.h),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 21.h),
      child: TextFormField(
        controller: controller.dateController,
        readOnly: true,
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'يرجى اختيار تاريخ بدء الدورة'
                    : null,
        decoration: _inputDecoration('تاريخ بدء الدورة'),
        onTap: () => controller.pickDate(Get.context!),
      ),
    );
  }
}
