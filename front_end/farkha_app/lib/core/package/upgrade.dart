import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constant/strings/update_strings.dart';
import '../../core/services/update_service.dart';
import '../../data/data_source/static/messages/upgrade_messages.dart';

class UpdateGate extends StatefulWidget {
  final Widget child;
  const UpdateGate({super.key, required this.child});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  late Future<UpdateAction> _checkFuture;
  bool _dialogShown = false;

  final Upgrader _iosUpgrader = Upgrader(
    messages: UpgradeMessages(),
    durationUntilAlertAgain: const Duration(days: 1),
    countryCode: 'EG',
  );

  @override
  void initState() {
    super.initState();
    _checkFuture = _runCheck();
  }

  Future<UpdateAction> _runCheck() async {
    final service = Get.find<UpdateService>();
    return service.check();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UpdateAction>(
      future: _checkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final action = snapshot.data ?? UpdateAction.none;

        if (Platform.isIOS) {
          return _buildIOS(action);
        }

        return _buildAndroid(action);
      },
    );
  }

  Widget _buildAndroid(UpdateAction action) {
    if (action == UpdateAction.force) {
      return _ForceUpdateScreen(
        onRetry: () async {
          final service = Get.find<UpdateService>();
          await service.triggerAndroidUpdate();
        },
      );
    }

    if (action == UpdateAction.optional && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showOptionalDialog();
      });
    }

    return widget.child;
  }

  Widget _buildIOS(UpdateAction action) {
    if (action == UpdateAction.force) {
      return _ForceUpdateScreen(
        onRetry: () async {
          final info = await PackageInfo.fromPlatform();
          final uri = Uri.parse(
            'https://apps.apple.com/app/id${info.packageName}',
          );
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      );
    }

    return UpgradeAlert(
      upgrader: _iosUpgrader,
      showIgnore: false,
      dialogStyle: UpgradeDialogStyle.cupertino,
      child: widget.child,
    );
  }

  Future<void> _showOptionalDialog() async {
    final service = Get.find<UpdateService>();
    if (service.action.value != UpdateAction.optional) return;
    await OptionalUpdateDialog.show();
  }
}

class _ForceUpdateScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const _ForceUpdateScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    size: 64.sp,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  UpdateStrings.forceTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  UpdateStrings.forceMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.shop),
                    label: Text(
                      UpdateStrings.updateNow,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
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

class OptionalUpdateDialog extends StatelessWidget {
  const OptionalUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Text(
        UpdateStrings.optionalTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        UpdateStrings.optionalMessage,
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () {
            final service = Get.find<UpdateService>();
            final code = service.lastAvailableVersionCode;
            if (code != null) {
              service.skipOptional(code);
            }
            Navigator.of(context).pop();
          },
          child: Text(
            UpdateStrings.later,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final service = Get.find<UpdateService>();
            await service.startFlexibleUpdate();
          },
          child: const Text(UpdateStrings.updateNow),
        ),
      ],
    );
  }

  static Future<void> show() async {
    await Get.dialog<void>(
      const OptionalUpdateDialog(),
      barrierDismissible: false,
    );
  }
}
