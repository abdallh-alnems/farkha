import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/strings/app_strings.dart';
import '../../../../core/constant/theme/theme.dart';
import '../../../../core/shared/buttons/app_button.dart';
import '../../../../core/shared/input_fields/input_field.dart';
import '../../../../logic/controller/cycle_sales_controller.dart';

void showAddSaleDialog(
    BuildContext context, CycleSalesController controller) {
  final colorScheme = Theme.of(context).colorScheme;
  final birdsCountController = TextEditingController();
  final weightController = TextEditingController();
  final priceController = TextEditingController();

  Get.dialog<void>(
    Dialog(
      backgroundColor: colorScheme.surface,
      shape:
          RoundedRectangleBorder(borderRadius: AppDimens.borderXl),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                        Icons.add_shopping_cart_rounded,
                        color: colorScheme.primary,
                        size: 22.sp),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      'إضافة عملية بيع',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              InputField(
                label: 'عدد الطيور',
                controller: birdsCountController,
                hintText: '0',
                enableValidation: false,
              ),
              SizedBox(height: 16.h),
              InputField(
                label: 'الوزن الكلي (كيلو)',
                controller: weightController,
                hintText: '0.0',
                enableValidation: false,
              ),
              SizedBox(height: 16.h),
              InputField(
                label: 'سعر الكيلو',
                controller: priceController,
                hintText: '0.0',
                suffixText: 'جنيه',
                enableValidation: false,
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: AppStrings.cancel,
                      variant: AppButtonVariant.text,
                      onPressed: () => Get.back<void>(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: Obx(() {
                      final isLoading = controller
                              .statusRequest.value ==
                          StatusRequest.loading;
                      return AppButton(
                        label: AppStrings.save,
                        loading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () {
                                final count = int.tryParse(
                                        birdsCountController
                                            .text) ??
                                    0;
                                final weight =
                                    double.tryParse(
                                            weightController.text) ??
                                        0.0;
                                final price = double.tryParse(
                                        priceController.text) ??
                                    0.0;
                                if (count > 0 &&
                                    weight > 0 &&
                                    price > 0) {
                                  controller.addSale(
                                    birdsCount: count,
                                    totalWeight: weight,
                                    pricePerKilo: price,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'يرجى إدخال قيم صحيحة',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight
                                                      .bold)),
                                      backgroundColor:
                                          AppColors.warningColor,
                                      behavior: SnackBarBehavior
                                          .floating,
                                      shape:
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          10.r)),
                                      margin:
                                          EdgeInsets.all(15.w),
                                    ),
                                  );
                                }
                              },
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showDeleteConfirmation(BuildContext context,
    CycleSalesController controller, SalesItem sale) {
  final colorScheme = Theme.of(context).colorScheme;

  Get.dialog<void>(
    AlertDialog(
      backgroundColor: colorScheme.surface,
      shape:
          RoundedRectangleBorder(borderRadius: AppDimens.borderXl),
      title: Text(
        AppStrings.confirmDelete,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
          fontSize: 18.sp,
        ),
      ),
      content: Text(
        'هل أنت متأكد من حذف عملية البيع؟ ${AppStrings.cannotUndo}',
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.5,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: Text(
            AppStrings.cancel,
            style: TextStyle(
                color: colorScheme.onSurface
                    .withValues(alpha: 0.6)),
          ),
        ),
        TextButton(
          onPressed: () {
            Get.back<void>();
            controller.deleteSale(sale.id);
          },
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.error,
            backgroundColor:
                colorScheme.error.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
                borderRadius: AppDimens.borderSm),
          ),
          child: const Text(AppStrings.delete,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
