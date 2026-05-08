import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/data_source/static/messages/upgrade_messages.dart';
import '../../logic/controller/remote_config_controller.dart';

/// يلفّ الشاشة الرئيسية ويعرض:
/// - شاشة تحديث إجباري (بدون "لاحقاً") عندما يكون الإصدار المُثبَّت أقل من
///   `min_version` المخزّن في Firebase Remote Config.
/// - حوار تحديث اختياري (مع "لاحقاً") عند توفّر إصدار أحدث في المتجر فقط.
class UpdateGate extends StatefulWidget {
  final Widget child;
  const UpdateGate({super.key, required this.child});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  late final Future<bool> _forceUpdateRequired;
  final Upgrader _upgrader = Upgrader(
    messages: UpgradeMessages(),
    durationUntilAlertAgain: const Duration(days: 17),
  );

  @override
  void initState() {
    super.initState();
    _forceUpdateRequired = _check();
  }

  Future<bool> _check() async {
    final controller = Get.find<RemoteConfigController>();
    await controller.fetchMinAppVersion();
    final info = await PackageInfo.fromPlatform();
    return _isLower(info.version, controller.minAppVersion);
  }

  bool _isLower(String current, String min) {
    int score(String v) {
      final parts = v.split('.').map((p) => int.tryParse(p) ?? 0).toList();
      while (parts.length < 3) {
        parts.add(0);
      }
      return parts[0] * 1000000 + parts[1] * 1000 + parts[2];
    }

    return score(current) < score(min);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _forceUpdateRequired,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _UpdateLoadingScreen();
        }
        if (snapshot.data == true) {
          return _ForceUpdateScreen(upgrader: _upgrader);
        }
        return UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.cupertino,
          showIgnore: false,
          upgrader: _upgrader,
          child: widget.child,
        );
      },
    );
  }
}

class _UpdateLoadingScreen extends StatelessWidget {
  const _UpdateLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ForceUpdateScreen extends StatefulWidget {
  final Upgrader upgrader;
  const _ForceUpdateScreen({required this.upgrader});

  @override
  State<_ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<_ForceUpdateScreen> {
  late final Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = widget.upgrader.initialize();
  }

  Future<void> _openStore() async {
    await _initFuture;
    await widget.upgrader.sendUserToAppStore();
    final url = widget.upgrader.versionInfo?.appStoreListingURL;
    if (url == null || url.isEmpty) {
      await _openStoreFallback();
    }
  }

  Future<void> _openStoreFallback() async {
    final info = await PackageInfo.fromPlatform();
    final Uri uri =
        Platform.isIOS
            ? Uri.parse('https://apps.apple.com/app/id${info.packageName}')
            : Uri.parse(
              'https://play.google.com/store/apps/details?id=${info.packageName}',
            );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.system_update_alt, size: 88.w, color: color),
                SizedBox(height: 24.h),
                Text(
                  'تحديث مطلوب',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'لقد قمنا بإصدار نسخة جديدة من تطبيق فرخة تحتوي على تحسينات وإصلاحات مهمة. يرجى تحديث التطبيق للمتابعة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.sp, height: 1.6),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openStore,
                    icon: const Icon(Icons.shop),
                    label: Text(
                      'تحديث الآن',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
