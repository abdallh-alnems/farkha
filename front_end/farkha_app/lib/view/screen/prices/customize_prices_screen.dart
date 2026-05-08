import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/constant/storage_keys.dart';
import '../../../core/constant/theme/theme.dart';
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
    if (!Get.isRegistered<CustomizePricesController>()) {
      Get.put(CustomizePricesController());
    }
    controller = Get.find<CustomizePricesController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorialIfNeeded();
    });
  }

  void _showTutorialIfNeeded() {
    final hasSeenTutorial =
        myServices.getStorage.read<bool>(StorageKeys.customizePricesTutorialSeen) ??
        false;
    final shouldShowTutorial =
        !hasSeenTutorial || TestModeManager.shouldShowTutorialEveryTime;

    if (shouldShowTutorial) {
      setState(() {
        _isTutorialActive = true;
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
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
    if (_isTutorialActive) {
      CustomizePricesTutorial.cancelTutorial();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (_isTutorialActive) {
          CustomizePricesTutorial.cancelTutorial();
          setState(() {
            _isTutorialActive = false;
          });
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(text: 'تخصيص الأسعار'),
        body: Obx(
          () => HandlingDataView(
            statusRequest: controller.statusRequest.value,
            widget: CustomScrollView(
              slivers: [
                if (!_isTutorialActive)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenH,
                        vertical: AppSpacing.sm,
                      ),
                      child: const AdNativeWidget(),
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                  ).copyWith(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.xxl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final String category = controller.categorizedTypes.keys
                          .elementAt(index);
                      final List<Map<String, dynamic>> types =
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 2.w,
              bottom: AppSpacing.sm,
              top: AppSpacing.xs,
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.w,
                childAspectRatio: 2.5,
              ),
              itemCount: controller.categorizedTypes[category]?.length ?? 0,
              itemBuilder: (context, index) {
                final currentTypes =
                    controller.categorizedTypes[category] ?? [];
                final item = currentTypes[index];
                return _buildTypeCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(Map<String, dynamic> item) {
    final bool isSelected = (item['isSelected'] as bool?) ?? false;
    final bool isNotificationOn =
        (item['isNotificationEnabled'] as bool?) ?? false;
    final bool isLocked = item['id'] == 1 && item['isSelected'] == true;
    final colorScheme = Theme.of(context).colorScheme;
    final bool effectivelySelected = isSelected || isLocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutQuart,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: effectivelySelected
            ? colorScheme.primary.withValues(alpha: 0.06)
            : colorScheme.surface,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: effectivelySelected
              ? colorScheme.primary.withValues(alpha: 0.2)
              : colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isLocked
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
              child: Text(
                (item['name'] ?? '').toString(),
                key:
                    item['id'] == 2
                        ? CustomizePricesTutorial.typeNameKey
                        : null,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight:
                      effectivelySelected ? FontWeight.w700 : FontWeight.w500,
                  color: effectivelySelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.55),
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          SizedBox(width: 6.w),

          _NotificationToggle(
            isActive: isNotificationOn,
            isLocked: isLocked,
            item: item,
            onTap: isLocked ? null : () => controller.toggleNotification(item),
            tutorialKey:
                item['id'] == 2
                    ? CustomizePricesTutorial.notificationIconKey
                    : null,
          ),

          SizedBox(width: 4.w),

          _SelectionToggle(
            isSelected: isSelected,
            isLocked: isLocked,
            onTap: isLocked ? null : () => controller.toggleItemSelection(item),
            tutorialKey:
                item['id'] == 2
                    ? CustomizePricesTutorial.selectionIndicatorKey
                    : null,
          ),
        ],
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final bool isActive;
  final bool isLocked;
  final Map<String, dynamic> item;
  final VoidCallback? onTap;
  final Key? tutorialKey;

  const _NotificationToggle({
    required this.isActive,
    required this.isLocked,
    required this.item,
    this.onTap,
    this.tutorialKey,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        key: tutorialKey,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuart,
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? AppColors.secondaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
        child: Icon(
          isActive
              ? Icons.notifications_active_rounded
              : Icons.notifications_off_outlined,
          size: 17.sp,
          color: isLocked
              ? colorScheme.primary.withValues(alpha: 0.6)
              : isActive
                  ? AppColors.secondaryColor
                  : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _SelectionToggle extends StatelessWidget {
  final bool isSelected;
  final bool isLocked;
  final VoidCallback? onTap;
  final Key? tutorialKey;

  const _SelectionToggle({
    required this.isSelected,
    required this.isLocked,
    this.onTap,
    this.tutorialKey,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool filled = isSelected || isLocked;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        key: tutorialKey,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuart,
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? colorScheme.primary : Colors.transparent,
          border: Border.all(
            color: filled
                ? colorScheme.primary
                : colorScheme.outline,
            width: filled ? 0 : 1.5,
          ),
        ),
        child: filled
            ? Icon(
                isLocked ? Icons.lock : Icons.check,
                size: isLocked ? 10.sp : 14.sp,
                color: colorScheme.onPrimary,
              )
            : null,
      ),
    );
  }
}
