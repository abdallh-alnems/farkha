import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_sales_controller.dart';
import '../../../logic/controller/cycle_expenses_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';

class CycleSalesScreen extends StatelessWidget {
  const CycleSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CycleSalesController>()) {
      Get.put(CycleSalesController());
    }
    
    final salesCtrl = Get.find<CycleSalesController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackGroundColor : AppColors.appBackGroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverToBoxAdapter(
            child: SizedBox(height: 10.h),
          ),
          SliverToBoxAdapter(
            child: _buildSummarySection(salesCtrl, isDark),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              child: const AdNativeWidget(),
            ),
          ),
          _buildSalesSliverList(salesCtrl, isDark),
          SliverToBoxAdapter(
            child: SizedBox(height: 100.h), // padding for FAB
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
      floatingActionButton: Obx(() {
        final cycleCtrl = Get.find<CycleController>();
        final role = cycleCtrl.currentCycle['role']?.toString() ?? 'owner';
        if (role == 'viewer') return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showAddSaleDialog(context, salesCtrl, isDark),
          elevation: 8,
          backgroundColor: AppColors.primaryColor,
          icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
          label: const Text('إضافة بيع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      backgroundColor: isDark ? AppColors.darkBackGroundColor : AppColors.appBackGroundColor,
      elevation: 0,
      stretch: true,
      pinned: true,
      expandedHeight: 120.h,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: isDark ? Colors.white : AppColors.primaryColor,
          ),
        ),
        onPressed: () => Get.back<void>(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(bottom: 16.h, right: 60.w, left: 60.w),
        centerTitle: true,
        title: Text(
          'سجل المبيعات',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(CycleSalesController controller, bool isDark) {
    final expensesCtrl = Get.find<CycleExpensesController>();
    return Obx(() {
      final totalSales = controller.totalSales.value;
      final totalExpenses = expensesCtrl.totalExpenses.value;
      final netProfit = totalSales - totalExpenses;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: LinearGradient(
            colors: isDark 
              ? [const Color(0xFF1E2833), const Color(0xFF151C24)]
              : [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : AppColors.primaryColor.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30.w,
              top: -30.h,
              child: CircleAvatar(
                radius: 70.r,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            Positioned(
              left: -40.w,
              bottom: -40.h,
              child: CircleAvatar(
                radius: 90.r,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Text(
                    'صافي الربح',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${netProfit.toStringAsFixed(0)} جـ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSubSummaryItem('المبيعات', totalSales.toStringAsFixed(0), Icons.arrow_upward_rounded, Colors.greenAccent),
                        Container(width: 1, height: 40.h, color: Colors.white.withValues(alpha: 0.2)),
                        _buildSubSummaryItem('المصروفات', totalExpenses.toStringAsFixed(0), Icons.arrow_downward_rounded, Colors.redAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubSummaryItem(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13.sp),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          '$value جـ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesSliverList(CycleSalesController controller, bool isDark) {
    return Obx(() {
      if (controller.statusRequest.value == StatusRequest.loading) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.sales.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sell_outlined, size: 60.sp, color: Colors.grey.withValues(alpha: 0.4)),
                ),
                SizedBox(height: 20.h),
                Text(
                  'لا توجد عمليات بيع مسجلة بعد',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final sale = controller.sales[index];
              return _buildSaleCard(context, controller, sale, isDark);
            },
            childCount: controller.sales.length,
          ),
        ),
      );
    });
  }

  Widget _buildSaleCard(BuildContext context, CycleSalesController controller, SalesItem sale, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.greenAccent : Colors.green).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14.sp, color: isDark ? Colors.greenAccent : Colors.green.shade700),
                          SizedBox(width: 8.w),
                          Text(
                            DateFormat('dd MMM yyyy').format(sale.saleDate),
                            style: TextStyle(
                              color: isDark ? Colors.greenAccent : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (Get.find<CycleController>().currentCycle['role']?.toString() != 'viewer')
                      IconButton(
                        icon: Icon(Icons.delete_sweep_rounded, color: Colors.redAccent.withValues(alpha: 0.8), size: 24.sp),
                        onPressed: () => _showDeleteConfirmation(context, controller, sale),
                        splashRadius: 24.r,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      sale.totalPrice.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Text(
                        'ج.م',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200], height: 1),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem('العدد', '${sale.birdsCount}', 'طائر', isDark),
                    _buildDetailItem('الوزن', sale.totalWeight.toStringAsFixed(0), 'كجم', isDark),
                    _buildDetailItem('السعر', sale.pricePerKilo.toStringAsFixed(0), 'جـ', isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, String unit, bool isDark) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showAddSaleDialog(BuildContext context, CycleSalesController controller, bool isDark) {
    final birdsCountController = TextEditingController();
    final weightController = TextEditingController();
    final priceController = TextEditingController();

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: isDark ? AppColors.darkSurfaceElevatedColor : Colors.white,
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
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_shopping_cart, color: AppColors.primaryColor, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'إضافة عملية بيع',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _buildTextField(birdsCountController, 'عدد الطيور', isDark, keyboardType: TextInputType.number),
                SizedBox(height: 16.h),
                _buildTextField(weightController, 'الوزن الكلي (كيلو)', isDark, keyboardType: TextInputType.number),
                SizedBox(height: 16.h),
                _buildTextField(priceController, 'سعر الكيلو اليوم', isDark, keyboardType: TextInputType.number),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back<void>(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: Obx(() {
                        final isLoading = controller.statusRequest.value == StatusRequest.loading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : () {
                            final count = int.tryParse(birdsCountController.text) ?? 0;
                            final weight = double.tryParse(weightController.text) ?? 0.0;
                            final price = double.tryParse(priceController.text) ?? 0.0;

                            if (count > 0 && weight > 0 && price > 0) {
                              controller.addSale(
                                birdsCount: count,
                                totalWeight: weight,
                                pricePerKilo: price,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('يرجى إدخال قيم صحيحة (العدد، الوزن، والسعر)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  backgroundColor: Colors.orange.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                  margin: EdgeInsets.all(15.w),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            backgroundColor: AppColors.primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : Text('حفظ الإضافة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isDark, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 14.sp, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceColor : Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.transparent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CycleSalesController controller, SalesItem sale) {
    Get.defaultDialog<void>(
      title: 'تأكيد الحذف',
      titlePadding: EdgeInsets.only(top: 24.h, bottom: 10.h),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      middleText: 'هل أنت متأكد من حذف حركة البيع المحددة؟ لا يمكن التراجع عن هذا الإجراء.',
      titleStyle: TextStyle(
        fontFamily: 'Cairo',
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w900,
        fontSize: 20.sp,
      ),
      middleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 15.sp,
        height: 1.5,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurfaceElevatedColor : Colors.white,
      radius: 24.r,
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        onPressed: () {
          Get.back<void>(); // إغلاق الحوار
          controller.deleteSale(sale.id); // استدعاء دالة الحذف
        },
        child: const Text('حذف', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      cancel: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        onPressed: () => Get.back<void>(),
        child: Text(
          'إلغاء',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
