import 'dart:async';
import 'dart:io' as java;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/package/rating_app.dart';
import '../../../core/services/dark_light_service.dart';
import '../../../core/services/open_privacy_policy.dart';

class DrawerAboutApp extends StatefulWidget {
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const DrawerAboutApp({
    super.key,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  @override
  State<DrawerAboutApp> createState() => _DrawerAboutAppState();
}

class _DrawerAboutAppState extends State<DrawerAboutApp>
    with WidgetsBindingObserver {
  bool _isNotificationEnabled = false;
  bool _isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionsStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkPermissionsStatus();
    }
  }

  Future<void> _checkPermissionsStatus() async {
    final notificationStatus = await Permission.notification.status;
    final locationStatus = await Permission.location.status;

    if (mounted) {
      setState(() {
        _isNotificationEnabled = notificationStatus.isGranted;
        _isLocationEnabled = locationStatus.isGranted;
      });
    }
  }

  Future<void> _handlePrivacyPolicy() async {
    Navigator.pop(context);
    unawaited(openPrivacyPolicy());
  }

  Future<void> _handleShareApp() async {
    Navigator.pop(context);
    unawaited(
      SharePlus.instance.share(
        ShareParams(
          text:
              'حمل تطبيق فرخة \n https://play.google.com/store/apps/details?id=ni.nims.frkha',
        ),
      ),
    );
  }

  Future<void> _handleRateApp() async {
    Navigator.pop(context);
    final rateController = Get.find<RateMyAppController>();
    rateController.launchStore();
  }

  Future<void> _handleLocationTap() async {
    try {
      Navigator.pop(context);
      await openAppSettings();
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkPermissionsStatus();
      });
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  Future<void> _handleNotificationTap() async {
    try {
      Navigator.pop(context);
      await openAppSettings();
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkPermissionsStatus();
      });
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  Future<void> _handleThemeToggle() async {
    // #region agent log
    try {
      final logFile = java.File(
        '/Users/nims/StudioProjects/farkha/front_end/farkha_app/.cursor/debug.log',
      );
      logFile.writeAsStringSync(
        '{"timestamp":${DateTime.now().millisecondsSinceEpoch},"message":"Toggling theme"}\n',
        mode: java.FileMode.append,
      );
    } catch (_) {}
    // #endregion
    final themeService = Get.find<DarkLightService>();
    themeService.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13).r,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey<bool>(widget.isExpanded),
          leading: Icon(
            Icons.settings_rounded,
            size: 21.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text('الإعدادات', style: TextStyle(fontSize: 15.sp)),
          trailing: const SizedBox.shrink(),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: widget.isExpanded,
          onExpansionChanged: (expanded) {
            widget.onExpansionChanged(expanded);
            if (expanded) {
              _checkPermissionsStatus();
            }
          },
          children: [
            ListTile(
              onTap: _handleLocationTap,
              title: Text('الموقع', style: TextStyle(fontSize: 15.sp)),
              trailing: Text(
                _isLocationEnabled ? 'مفعل' : 'غير مفعل',
                style: TextStyle(
                  fontSize: 14.sp,
                  color:
                      _isLocationEnabled
                          ? Colors.green
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
            ListTile(
              onTap: _handleNotificationTap,
              title: Text('الإشعارات', style: TextStyle(fontSize: 15.sp)),
              trailing: Text(
                _isNotificationEnabled ? 'مفعل' : 'غير مفعل',
                style: TextStyle(
                  fontSize: 14.sp,
                  color:
                      _isNotificationEnabled
                          ? Colors.green
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
            ListTile(
              onTap: _handleThemeToggle,
              title: Text('الوضع الليلي', style: TextStyle(fontSize: 15.sp)),
              trailing: Obx(() {
                final themeService = Get.find<DarkLightService>();
                final isDark =
                    themeService.themeMode.value == ThemeMode.dark ||
                    (themeService.themeMode.value == ThemeMode.system &&
                        MediaQuery.of(context).platformBrightness ==
                            Brightness.dark);

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    key: ValueKey<bool>(isDark),
                    color:
                        isDark ? Colors.grey.shade300 : Colors.orange.shade600,
                    size: 26.sp,
                  ),
                );
              }),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
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
            ListTile(
              onTap: _handlePrivacyPolicy,
              title: Text('سياسة الخصوصية', style: TextStyle(fontSize: 15.sp)),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
          ],
        ),
      ),
    );
  }
}
