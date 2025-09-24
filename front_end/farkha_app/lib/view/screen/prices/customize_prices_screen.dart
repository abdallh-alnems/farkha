import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/constant/theme/color.dart';
import '../../../logic/controller/price_controller/prices_stream/customize_prices_controller.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class CustomizePricesScreen extends StatefulWidget {
  const CustomizePricesScreen({super.key});

  @override
  State<CustomizePricesScreen> createState() => _CustomizePricesScreenState();
}

class _CustomizePricesScreenState extends State<CustomizePricesScreen> {
  late CustomizePricesController controller;

  @override
  void initState() {
    super.initState();
    // تسجيل الـ controller إذا لم يكن مسجلاً
    if (!Get.isRegistered<CustomizePricesController>()) {
      Get.put(CustomizePricesController());
    }
    controller = Get.find<CustomizePricesController>();
    print('✅ CustomizePricesScreen initialized');
    print('✅ Controller status: ${controller.statusRequest.value}');
    print('✅ Categories count: ${controller.categorizedTypes.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(text: 'تخصيص الأسعار', showIcon: false),
      body: Container(
        color: AppColor.appBackGroundColor,
        child: Column(
          children: [
            // Content Section
            Expanded(
              child: Obx(
                () => HandlingDataView(
                  statusRequest: controller.statusRequest.value,
                  widget: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 21.r,
                      vertical: 19.r,
                    ),
                    child:
                        controller.categorizedTypes.isEmpty
                            ? const Center(
                              child: Text(
                                'لا توجد بيانات للعرض',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                            : ListView.builder(
                              itemCount: controller.categorizedTypes.length,
                              itemBuilder: (context, index) {
                                String category = controller
                                    .categorizedTypes
                                    .keys
                                    .elementAt(index);
                                List<Map<String, dynamic>> types =
                                    controller.categorizedTypes[category]!;
                                return _buildCategorySection(category, types);
                              },
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    String category,
    List<Map<String, dynamic>> types,
  ) {
    Color categoryColor = AppColor.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Title
        Padding(
          padding: EdgeInsets.only(right: 5.r, bottom: 10.h, top: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(width: 11.w),
              Container(
                width: 6.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ],
          ),
        ),

        // Types Grid
        Obx(
          () => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 11.w,
              mainAxisSpacing: 11.h,
              childAspectRatio: 3.3,
            ),
            itemCount: controller.categorizedTypes[category]?.length ?? 0,
            itemBuilder: (context, index) {
              // حساب الموقع في الشبكة للترتيب من اليمين إلى اليسار
              int row = index ~/ 2;
              int col = index % 2;
              // عكس العمود لتبدأ من اليمين
              int reversedCol = 1 - col;
              int reversedIndex = row * 2 + reversedCol;

              // التأكد من أن المؤشر ضمن النطاق
              final currentTypes = controller.categorizedTypes[category] ?? [];
              if (reversedIndex < currentTypes.length) {
                final item = currentTypes[reversedIndex];
                return _buildTypeCard(item, categoryColor);
              } else {
                // إذا كان المؤشر خارج النطاق، استخدم العنصر الأصلي
                final item = currentTypes[index];
                return _buildTypeCard(item, categoryColor);
              }
            },
          ),
        ),
        SizedBox(height: 9.h),
      ],
    );
  }

  Widget _buildTypeCard(Map<String, dynamic> item, Color categoryColor) {
    // التحقق من أن اللحم الأبيض (ID: 1) محدد ولا يمكن إلغاء تحديده
    bool isLocked = item['id'] == 1 && item['isSelected'] == true;

    return GestureDetector(
      onTap: () => controller.toggleItemSelection(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 13.r, vertical: 8.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color:
                isLocked
                    ? AppColor.primaryColor.withOpacity(0.7)
                    : item['isSelected']
                    ? AppColor.primaryColor
                    : Colors.grey.withOpacity(0.3),
            width: item['isSelected'] ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Selection Indicator with Animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isLocked
                        ? AppColor.primaryColor.withOpacity(0.7)
                        : item['isSelected']
                        ? AppColor.primaryColor
                        : Colors.transparent,
                border: Border.all(
                  color:
                      isLocked
                          ? AppColor.primaryColor.withOpacity(0.7)
                          : item['isSelected']
                          ? AppColor.primaryColor
                          : Colors.black,
                  width: item['isSelected'] ? 0 : 2,
                ),
              ),
              child:
                  isLocked
                      ? Icon(
                        Icons.lock,
                        size: 14.sp,
                        color: Colors.white,
                        weight: 900,
                      )
                      : item['isSelected']
                      ? Icon(
                        Icons.check,
                        size: 16.sp,
                        color: Colors.white,
                        weight: 900,
                      )
                      : null,
            ),

            // Type Name
            Expanded(
              child: Text(
                item['name'],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight:
                      isLocked
                          ? FontWeight.w700
                          : item['isSelected']
                          ? FontWeight.w700
                          : FontWeight.w600,
                  color:
                      isLocked ? Colors.black.withOpacity(0.8) : Colors.black,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
