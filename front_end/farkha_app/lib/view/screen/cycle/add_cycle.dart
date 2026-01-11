// lib/views/screens/add_cycle.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/functions/input_validation.dart';
import '../../../logic/controller/cycle_controller.dart';

class AddCycle extends StatelessWidget {
  AddCycle({super.key});
  final CycleController controller = Get.find<CycleController>();

  bool _isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _getBackgroundColor(BuildContext context) {
    return _isDarkMode(context)
        ? AppColors.darkBackGroundColor
        : AppColors.appBackGroundColor;
  }

  Color _getSurfaceColor(BuildContext context) {
    return _isDarkMode(context)
        ? AppColors.darkSurfaceColor
        : AppColors.lightSurfaceColor;
  }

  Color _getPrimaryColor(BuildContext context) {
    return _isDarkMode(context)
        ? AppColors.darkPrimaryColor
        : AppColors.primaryColor;
  }

  Color _getTextColor(BuildContext context) {
    return _isDarkMode(context) ? Colors.white : Colors.black;
  }

  Color _getBorderColor(BuildContext context) {
    return _isDarkMode(context)
        ? AppColors.darkOutlineColor
        : Colors.black.withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // مسح الحقول عند الخروج من الصفحة (فقط عند إضافة دورة جديدة وليس تعديل)
        if (didPop) {
          // إذا كان في وضع التعديل، لا نمسح الحقول لأنها قد تكون محملة من دورة موجودة
          // إذا لم يكن في وضع التعديل، نمسح الحقول عند الخروج
          if (!controller.isEdit.value) {
            controller.clearFields();
          }
        }
      },
      child: Scaffold(
        backgroundColor: _getBackgroundColor(context),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, Colors.deepPurple.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    _buildHeader(context),
                    Expanded(child: _buildForm(context)),
                  ],
                ),
              ),
              Obx(() {
                final saveStatus = controller.cycleSaveStatus.value;
                final deleteStatus = controller.cycleDeleteStatus.value;
                
                // إظهار حالة التحميل للحفظ
                if (saveStatus == StatusRequest.loading ||
                    saveStatus == StatusRequest.serverFailure ||
                    saveStatus == StatusRequest.offlineFailure ||
                    saveStatus == StatusRequest.failure) {
                  return Positioned.fill(
                    child: IgnorePointer(
                      ignoring: saveStatus != StatusRequest.loading,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black.withOpacity(0.7),
                        child: HandlingDataView(
                          statusRequest: saveStatus,
                          widget: const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  );
                }
                
                // إظهار حالة التحميل للحذف
                if (deleteStatus == StatusRequest.loading ||
                    deleteStatus == StatusRequest.serverFailure ||
                    deleteStatus == StatusRequest.offlineFailure ||
                    deleteStatus == StatusRequest.failure) {
                  return Positioned.fill(
                    child: IgnorePointer(
                      ignoring: deleteStatus != StatusRequest.loading,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black.withOpacity(0.7),
                        child: HandlingDataView(
                          statusRequest: deleteStatus,
                          widget: const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  );
                }
                
                // إغلاق الصفحة بعد نجاح الحذف
                if (deleteStatus == StatusRequest.success) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (Get.isDialogOpen != true) {
                      controller.cycleDeleteStatus.value = StatusRequest.none;
                      Get.back();
                    }
                  });
                }
                
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textColor = Colors.white;

    return Padding(
      padding: EdgeInsets.only(top: 11.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // علامة X (إغلاق) في اليسار
          Padding(
            padding: EdgeInsets.only(left: 11.w),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.close, color: textColor, size: 25.sp),
            ),
          ),
          // العنوان في الوسط
          Expanded(
            child: Obx(
              () => Text(
                controller.isEdit.value ? 'تعديل الدورة' : 'إضافة دورة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 23.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // مساحة فارغة للحفاظ على التوازن
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final isDark = _isDarkMode(context);
    final surfaceColor = _getSurfaceColor(context);
    final textColor = _getTextColor(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25.w, vertical: 9.h),
      padding: EdgeInsets.symmetric(vertical: 31.h, horizontal: 19.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 21.h),
                child: TextFormField(
                  controller: controller.nameController,
                  keyboardType: TextInputType.name,
                  style: TextStyle(color: textColor),
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
                  decoration: _inputDecoration(context, 'اسم الدورة'),
                ),
              ),
              _buildFixedField(
                context: context,
                label: 'نوع الدورة',
                value: 'تسمين',
              ),
              _buildFixedField(
                context: context,
                label: 'نوع السلالة',
                value: 'تسمين',
              ),
              _buildTextField(
                context: context,
                label: 'عدد الفراخ',
                controller: controller.countController,
                keyboardType: TextInputType.number,
                validator: InputValidation.validateAndFormatNumber,
                suffix: ' فرخ',
              ),
              _buildTextField(
                context: context,
                label: 'مساحة العنبر',
                controller: controller.spaceController,
                keyboardType: TextInputType.number,
                validator: InputValidation.validateAndFormatNumber,
                suffix: 'م2',
              ),
              _buildFixedField(
                context: context,
                label: 'نظام التربية',
                value: 'أرضي',
              ),
              _buildDateField(context),
              SizedBox(height: 25.h),
              Center(
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
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

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final isDark = _isDarkMode(context);
    final borderColor = _getBorderColor(context);
    final primaryColor = _getPrimaryColor(context);
    final surfaceColor = _getSurfaceColor(context);
    final textColor = _getTextColor(context);

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceElevatedColor : surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? suffix,
  }) {
    final textColor = _getTextColor(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 21.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        validator:
            validator ??
            (value) =>
                value == null || value.isEmpty ? 'يرجى إدخال $label' : null,
        decoration: _inputDecoration(context, label).copyWith(
          suffixText: suffix,
          suffixStyle: TextStyle(color: textColor.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildFixedField({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final textColor = _getTextColor(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 21.h),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        style: TextStyle(color: textColor.withOpacity(0.7)),
        decoration: _inputDecoration(context, label),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final textColor = _getTextColor(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 21.h),
      child: TextFormField(
        controller: controller.dateController,
        readOnly: true,
        style: TextStyle(color: textColor),
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'يرجى اختيار تاريخ بدء الدورة'
                    : null,
        decoration: _inputDecoration(context, 'تاريخ بدء الدورة'),
        onTap: () => controller.pickDate(Get.context!),
      ),
    );
  }
}
