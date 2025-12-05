import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/services/initialization.dart';
import '../../../core/services/test_mode_manager.dart';
import '../../../logic/controller/price_controller/prices_card/customize_prices_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tutorial/customize_prices_tutorial.dart';

class CustomizePricesScreen extends StatefulWidget {
  const CustomizePricesScreen({super.key});

  @override
  State<CustomizePricesScreen> createState() => _CustomizePricesScreenState();
}

class _CustomizePricesScreenState extends State<CustomizePricesScreen> {
  late CustomizePricesController controller;
  bool _isTutorialActive = false;
  MyServices myServices = Get.find();

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

    // إظهار الـ tutorial بعد بناء الـ widgets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorialIfNeeded();
    });
  }

  void _showTutorialIfNeeded() {
    // التحقق من أن المستخدم لم يشاهد الـ tutorial من قبل
    final hasSeenTutorial =
        myServices.getStorage.read<bool>('customize_prices_tutorial_seen') ??
        false;

    // إظهار الشرح إذا لم يشاهده من قبل أو إذا كان في وضع الاختبار
    final shouldShowTutorial =
        !hasSeenTutorial || TestModeManager.shouldShowTutorialEveryTime;

    if (shouldShowTutorial) {
      // إخفاء الاعلانات فوراً قبل إظهار الشرح
      setState(() {
        _isTutorialActive = true;
      });

      // تأخير قصير للتأكد من تحميل البيانات
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          // إظهار الـ tutorial مع callback عند الانتهاء
          CustomizePricesTutorial.showTutorial(
            context,
            onTutorialComplete: () {
              if (mounted) {
                setState(() {
                  _isTutorialActive = false;
                });
              }
            },
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // إلغاء الشرح إذا كان يعمل عند الخروج من الصفحة
    if (_isTutorialActive) {
      CustomizePricesTutorial.cancelTutorial();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // إلغاء الشرح عند الضغط على زر الرجوع
        if (_isTutorialActive) {
          CustomizePricesTutorial.cancelTutorial();
          setState(() {
            _isTutorialActive = false;
          });
        }
        return true; // السماح بالرجوع
      },
      child: Scaffold(
        appBar: const CustomAppBar(text: 'تخصيص الأسعار'),
        body: Obx(
          () => HandlingDataView(
            statusRequest: controller.statusRequest.value,
            widget: CustomScrollView(
              slivers: [
                // Native Ad at the top (scrollable) - إخفاء أثناء الـ tutorial
                if (!_isTutorialActive)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 21.r,
                        vertical: 10.h,
                      ),
                      child: const AdNativeWidget(),
                    ),
                  ),

                // Content Section
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 21.r,
                    vertical: 19.r,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      String category = controller.categorizedTypes.keys
                          .elementAt(index);
                      List<Map<String, dynamic>> types =
                          controller.categorizedTypes[category]!;
                      return _buildCategorySection(category, types);
                    }, childCount: controller.categorizedTypes.length),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _isTutorialActive ? null : const AdBannerWidget(),
      ),
    );
  }

  Widget _buildCategorySection(
    String category,
    List<Map<String, dynamic>> types,
  ) {
    Color categoryColor = AppColors.primaryColor;

    return Column(
      children: [
        // Category Title
        Padding(
          padding: EdgeInsets.only(right: 5.r, bottom: 10.h, top: 6.h),
          child: Row(
            children: [
              Container(
                width: 6.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              SizedBox(width: 11.w),

              Text(
                category,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.8,
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
              final currentTypes = controller.categorizedTypes[category] ?? [];
              final item = currentTypes[index];
              return _buildTypeCard(item, categoryColor);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 13.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevatedColor
            : AppColors.lightSurfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color:
              isDark
                  ? AppColors.darkOutlineColor.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Type Name (right side)
          Expanded(
            child: GestureDetector(
              onTap:
                  isLocked
                      ? null
                      : () {
                        if (item['isSelected'] == true &&
                            item['isNotificationEnabled'] == true) {
                          controller.toggleItemSelection(item);
                          controller.toggleNotification(item);
                        } else {
                          if (item['isSelected'] != true) {
                            controller.toggleItemSelection(item);
                          }
                          if (item['isNotificationEnabled'] != true) {
                            controller.toggleNotification(item);
                          }
                        }
                      },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 1, maxWidth: 150.w),
                  child: Text(
                    item['name'],
                    key:
                        item['id'] == 2
                            ? CustomizePricesTutorial.typeNameKey
                            : null,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                          isLocked
                              ? FontWeight.w700
                              : item['isSelected']
                              ? FontWeight.w700
                              : FontWeight.w600,
                      color:
                          isLocked
                              ? colorScheme.onSurface.withOpacity(0.8)
                              : colorScheme.onSurface,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Notification Bell Icon
          GestureDetector(
            onTap: isLocked ? null : () => controller.toggleNotification(item),
            child: AnimatedContainer(
              key:
                  item['id'] == 2
                      ? CustomizePricesTutorial.notificationIconKey
                      : null,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    item['isNotificationEnabled'] == true
                        ? (isDark
                            ? Colors.white.withOpacity(0.15)
                            : AppColors.primaryColor.withOpacity(0.1))
                        : Colors.transparent,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    item['isNotificationEnabled'] == true
                        ? Icons.notifications_active
                        : Icons.notifications_off_outlined,
                    size: 20.sp,
                    color:
                        isLocked
                            ? (isDark
                                ? Colors.white
                                : AppColors.primaryColor.withOpacity(0.7))
                            : item['isNotificationEnabled'] == true
                            ? Colors.amber
                            : (isDark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.grey),
                  ),
                  if (isLocked)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1.r),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock,
                          size: 8.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Selection Indicator (left side)
          GestureDetector(
            onTap: isLocked ? null : () => controller.toggleItemSelection(item),
            child: AnimatedContainer(
              key:
                  item['id'] == 2
                      ? CustomizePricesTutorial.selectionIndicatorKey
                      : null,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 19.w,
              height: 19.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isLocked
                        ? (isDark
                            ? Colors.white
                            : AppColors.primaryColor.withOpacity(0.7))
                        : item['isSelected']
                        ? (isDark
                            ? Colors.white
                            : AppColors.primaryColor)
                        : Colors.transparent,
                border: Border.all(
                  color:
                      isLocked
                          ? (isDark
                              ? Colors.white
                              : AppColors.primaryColor.withOpacity(0.7))
                          : item['isSelected']
                          ? (isDark
                              ? Colors.white
                              : AppColors.primaryColor)
                          : (isDark
                              ? Colors.white.withOpacity(0.6)
                              : colorScheme.onSurface),
                  width: item['isSelected'] ? 0 : 2,
                ),
              ),
              child:
                  isLocked
                      ? Icon(
                        Icons.lock,
                        size: 12.sp,
                        color: isDark
                            ? AppColors.darkBackGroundColor
                            : Colors.white,
                        weight: 900,
                      )
                      : item['isSelected']
                      ? Icon(
                        Icons.check,
                        size: 14.sp,
                        color: isDark
                            ? AppColors.darkBackGroundColor
                            : Colors.white,
                        weight: 900,
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
