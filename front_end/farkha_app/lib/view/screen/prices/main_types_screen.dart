import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/constant/routes/route.dart';
import '../../../core/constant/theme/theme.dart';
import '../../../logic/controller/price_controller/main_types_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';

class MainTypes extends StatelessWidget {
  const MainTypes({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MainTypesController());

    return Scaffold(
      appBar: const CustomAppBar(text: 'الأنواع'),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<MainTypesController>(
              builder: (controller) {
                return HandlingDataView(
                  statusRequest: controller.statusRequest,
                  widget: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenH,
                      vertical: AppSpacing.sm,
                    ),
                    children: [
                      const AdNativeWidget(),
                      SizedBox(height: AppSpacing.md),
                      ...List.generate(controller.items.length, (index) {
                        final item = controller.items[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < controller.items.length - 1
                                ? AppSpacing.sm
                                : 0,
                          ),
                          child: _TypeCard(
                            name: (item['name'] ?? '').toString(),
                            index: index,
                            onTap: () => Get.toNamed<void>(
                              AppRoute.pricesByType,
                              arguments: {
                                'main_id': item['id'],
                                'main_name': (item['name'] ?? '').toString(),
                              },
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}

class _TypeCard extends StatefulWidget {
  final String name;
  final int index;
  final VoidCallback onTap;

  const _TypeCard({
    required this.name,
    required this.index,
    required this.onTap,
  });

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            child: Ink(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevatedColor
                    : AppColors.lightCardBackgroundColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2.h,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
