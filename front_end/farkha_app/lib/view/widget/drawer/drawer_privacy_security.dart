import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/open_privacy_policy.dart';

class DrawerPrivacySecurity extends StatefulWidget {
  const DrawerPrivacySecurity({super.key});

  @override
  State<DrawerPrivacySecurity> createState() => _DrawerPrivacySecurityState();
}

class _DrawerPrivacySecurityState extends State<DrawerPrivacySecurity>
    with WidgetsBindingObserver {
  bool _isExpanded = false;
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
    // تحديث الحالة عند العودة من إعدادات النظام
    if (state == AppLifecycleState.resumed) {
      _checkPermissionsStatus();
    }
  }

  Future<void> _checkPermissionsStatus() async {
    final notificationStatus = await Permission.notification.status;
    final locationStatus = await Permission.location.status;

    if (mounted) {
      setState(() {
        // الإشعارات مفعلة إذا كانت الأذونات مفعلة
        _isNotificationEnabled = notificationStatus.isGranted;
        // الموقع مفعل إذا كانت الأذونات مفعلة
        _isLocationEnabled = locationStatus.isGranted;
      });
    }
  }

  Future<void> _handlePrivacyPolicy() async {
    Navigator.pop(context);
    openPrivacyPolicy();
  }

  Future<void> _handleLocationTap() async {
    try {
      Navigator.pop(context); // إغلاق الـ drawer
      await openAppSettings();
      // تحديث الحالة عند العودة من الإعدادات
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkPermissionsStatus();
      });
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  Future<void> _handleNotificationTap() async {
    try {
      Navigator.pop(context); // إغلاق الـ drawer
      await openAppSettings();
      // تحديث الحالة عند العودة من الإعدادات
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkPermissionsStatus();
      });
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13).r,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.lock_outline_rounded,
            size: 21.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text('الخصوصية والأمان', style: TextStyle(fontSize: 15.sp)),
          trailing: const SizedBox.shrink(),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
            // Refresh permission status when expanding
            if (expanded) {
              _checkPermissionsStatus();
            }
          },
          children: [
            ListTile(
              onTap: _handlePrivacyPolicy,
              title: Text('سياسة الخصوصية', style: TextStyle(fontSize: 15.sp)),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
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
          ],
        ),
      ),
    );
  }
}
