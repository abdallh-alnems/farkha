import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/package/rating_app.dart';
import '../../../core/services/dark_light_service.dart';

class DrawerAboutApp extends StatefulWidget {
  const DrawerAboutApp({super.key});

  @override
  State<DrawerAboutApp> createState() => _DrawerAboutAppState();
}

class _DrawerAboutAppState extends State<DrawerAboutApp> {
  bool _isExpanded = false;
  static final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  Future<void> _handleShareApp() async {
    Navigator.pop(context);
    SharePlus.instance.share(
      ShareParams(
        text:
            'حمل تطبيق فرخة \n https://play.google.com/store/apps/details?id=ni.nims.frkha',
      ),
    );
  }

  Future<void> _handleRateApp() async {
    Navigator.pop(context);
    final rateController = Get.find<RateMyAppController>();
    rateController.launchStore();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13).r,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.info_outline_rounded,
            size: 21.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text('عن التطبيق', style: TextStyle(fontSize: 15.sp)),
          trailing: const SizedBox.shrink(),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            ListTile(
              onTap: _handleRateApp,
              title: Text('تقييم التطبيق', style: TextStyle(fontSize: 15.sp)),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
            ListTile(
              onTap: _handleShareApp,
              title: Text('مشاركة التطبيق', style: TextStyle(fontSize: 15.sp)),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
            FutureBuilder<PackageInfo>(
              future: _packageInfoFuture,
              builder: (context, snapshot) {
                final version =
                    snapshot.hasData ? snapshot.data!.version : '...';
                return ListTile(
                  title: Text('رقم الإصدار', style: TextStyle(fontSize: 15.sp)),
                  trailing: Text(
                    version,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  shape: const Border(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
                );
              },
            ),
            _buildThemeToggle(),
          ],
        ),
      ),
    );
  }

  bool _getIsDark(BuildContext context, ThemeMode currentMode) {
    if (currentMode == ThemeMode.dark) {
      return true;
    } else if (currentMode == ThemeMode.light) {
      return false;
    } else {
      // إذا كان system، نتحقق من الوضع الفعلي للهاتف
      final Brightness systemBrightness =
          MediaQuery.of(context).platformBrightness;
      return systemBrightness == Brightness.dark;
    }
  }

  Widget _buildThemeToggle() {
    final DarkLightService themeService = Get.find<DarkLightService>();
    const Color sunColor = Color(0xFFFFA500); // لون برتقالي/أصفر للشمس
    const Color moonColor = Color(0xFFC0C0C0); // لون فضي للقمر

    return Obx(() {
      final ThemeMode currentMode = themeService.themeMode.value;
      final bool isDark = _getIsDark(context, currentMode);
      final colorScheme = Theme.of(context).colorScheme;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.light_mode,
                color: isDark ? sunColor.withValues(alpha: 0.4) : sunColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Switch(
                value: isDark,
                onChanged: (_) => themeService.toggleTheme(),
                activeThumbColor: colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.dark_mode,
                color: isDark ? moonColor : moonColor.withValues(alpha: 0.4),
                size: 20.sp,
              ),
            ],
          ),
        ),
      );
    });
  }
}
