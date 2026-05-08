import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../core/functions/input_validation.dart';
import '../../../core/shared/buttons/app_button.dart';
import '../../../logic/controller/cycle_controller.dart';

class AddCycleScreen extends StatefulWidget {
  const AddCycleScreen({super.key});

  @override
  State<AddCycleScreen> createState() => _AddCycleScreenState();
}

class _AddCycleScreenState extends State<AddCycleScreen>
    with SingleTickerProviderStateMixin {
  final CycleController controller = Get.find<CycleController>();
  late final AnimationController _animController;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const int _fieldCount = 6;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnims = List.generate(_fieldCount, (i) {
      return CurvedAnimation(
        parent: _animController,
        curve: Interval(
          0.05 + (i * 0.07),
          0.4 + (i * 0.08),
          curve: Curves.easeOutQuint,
        ),
      );
    });

    _slideAnims = List.generate(_fieldCount, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(
            0.05 + (i * 0.07),
            0.4 + (i * 0.08),
            curve: Curves.easeOutQuint,
          ),
        ),
      );
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !controller.isEdit.value) {
          controller.clearFields();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildForm(context)),
                ],
              ),
              Obx(() => _buildLoadingOverlay()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, AppColors.primaryLight],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 4.w),
            child: IconButton(
              onPressed: () => Get.back<void>(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onPrimary,
                size: 24.sp,
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => Text(
                controller.isEdit.value ? 'تعديل الدورة' : 'إضافة دورة جديدة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.35),
        ),
        boxShadow: isDark ? null : [AppElevation.shadow()],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _animatedField(0, _buildNameField(colorScheme)),
              _animatedField(
                1,
                _buildInfoChipRow(colorScheme),
              ),
              _animatedField(
                2,
                _buildNumberField(
                  colorScheme: colorScheme,
                  label: 'عدد الفراخ',
                  textController: controller.countController,
                  suffix: 'فرخ',
                  icon: Icons.egg_rounded,
                ),
              ),
              _animatedField(
                3,
                _buildNumberField(
                  colorScheme: colorScheme,
                  label: 'مساحة العنبر',
                  textController: controller.spaceController,
                  suffix: 'م²',
                  icon: Icons.straighten_rounded,
                ),
              ),
              _animatedField(4, _buildDateField(colorScheme)),
              SizedBox(height: 24.h),
              _animatedField(
                5,
                Obx(
                  () => AppButton(
                    label: controller.isEdit.value
                        ? 'حفظ التعديلات'
                        : 'إنشاء الدورة',
                    icon: controller.isEdit.value
                        ? Icons.check_rounded
                        : Icons.add_rounded,
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

  Widget _animatedField(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(
        position: _slideAnims[index],
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNameField(ColorScheme colorScheme) {
    return TextFormField(
      controller: controller.nameController,
      keyboardType: TextInputType.name,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
      ),
      validator: (value) {
        final name = value?.trim() ?? '';
        if (name.isEmpty) return 'يرجى إدخال اسم الدورة';
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
      decoration: InputDecoration(
        labelText: 'اسم الدورة',
        prefixIcon: Icon(
          Icons.label_rounded,
          size: 20.sp,
          color: colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required ColorScheme colorScheme,
    required String label,
    required TextEditingController textController,
    required String suffix,
    required IconData icon,
  }) {
    return TextFormField(
      controller: textController,
      keyboardType: TextInputType.number,
      inputFormatters: [_DigitFormatter()],
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
      ),
      validator: InputValidation.validateAndFormatNumber,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 20.sp,
          color: colorScheme.onSurface.withValues(alpha: 0.45),
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChipRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _infoChip(
            colorScheme,
            icon: Icons.pets_rounded,
            label: 'نوع الدورة',
            value: 'تسمين',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _infoChip(
            colorScheme,
            icon: Icons.grid_view_rounded,
            label: 'نظام التربية',
            value: 'أرضي',
          ),
        ),
      ],
    );
  }

  Widget _infoChip(
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  height: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(ColorScheme colorScheme) {
    return TextFormField(
      controller: controller.dateController,
      readOnly: true,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى اختيار تاريخ بدء الدورة';
        }
        final dateRawText = controller.dateRawController.text.trim();
        if (dateRawText.isEmpty) return 'تاريخ غير صحيح';
        final selectedDate = DateTime.tryParse(dateRawText);
        if (selectedDate == null) return 'تاريخ غير صحيح';
        final thirtyNineDaysAgo = DateTime.now().subtract(
          const Duration(days: 39),
        );
        if (selectedDate.isBefore(thirtyNineDaysAgo)) {
          return 'يجب أن يكون التاريخ ضمن آخر 39 يوم';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'تاريخ بدء الدورة',
        prefixIcon: Icon(
          Icons.calendar_today_rounded,
          size: 20.sp,
          color: colorScheme.onSurface.withValues(alpha: 0.45),
        ),
        suffixIcon: Icon(
          Icons.arrow_drop_down_rounded,
          size: 24.sp,
          color: colorScheme.primary.withValues(alpha: 0.6),
        ),
      ),
      onTap: () => controller.pickDate(Get.context!),
    );
  }

  Widget _buildLoadingOverlay() {
    final saveStatus = controller.cycleSaveStatus.value;
    final deleteStatus = controller.cycleDeleteStatus.value;

    if (saveStatus == StatusRequest.loading ||
        saveStatus == StatusRequest.serverFailure ||
        saveStatus == StatusRequest.offlineFailure ||
        saveStatus == StatusRequest.failure) {
      return Positioned.fill(
        child: IgnorePointer(
          ignoring: saveStatus != StatusRequest.loading,
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.6),
            child: HandlingDataView(
              statusRequest: saveStatus,
              widget: const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }

    if (deleteStatus == StatusRequest.loading ||
        deleteStatus == StatusRequest.serverFailure ||
        deleteStatus == StatusRequest.offlineFailure ||
        deleteStatus == StatusRequest.failure) {
      return Positioned.fill(
        child: IgnorePointer(
          ignoring: deleteStatus != StatusRequest.loading,
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.6),
            child: HandlingDataView(
              statusRequest: deleteStatus,
              widget: const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }

    if (deleteStatus == StatusRequest.success) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.isDialogOpen != true) {
          controller.cycleDeleteStatus.value = StatusRequest.none;
          Get.back<void>();
        }
      });
    }

    return const SizedBox.shrink();
  }
}

class _DigitFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = InputValidation.normalizeToEnglishDigits(newValue.text);
    if (normalized == newValue.text) return newValue;
    final offset = newValue.selection.baseOffset.clamp(0, normalized.length);
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
