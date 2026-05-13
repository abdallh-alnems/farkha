import 'dart:io' show Platform;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constant/storage_keys.dart';
import '../constant/strings/update_strings.dart';
import '../utils/version_compare.dart';

enum UpdateAction { none, optional, force }

class UpdateService extends GetxService {
  final _box = GetStorage();
  bool _checking = false;
  DateTime? _lastCheckTime;
  int? _lastAvailableVersionCode;

  final Rx<UpdateAction> action = UpdateAction.none.obs;
  int? get lastAvailableVersionCode => _lastAvailableVersionCode;

  static const _minRecheckInterval = Duration(minutes: 5);

  Future<UpdateAction> check() async {
    if (_checking) return UpdateAction.none;
    _checking = true;
    try {
      final now = DateTime.now();
      if (_lastCheckTime != null &&
          now.difference(_lastCheckTime!) < _minRecheckInterval) {
        return action.value;
      }
      _lastCheckTime = now;

      await FirebaseRemoteConfig.instance.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );
      await FirebaseRemoteConfig.instance.fetchAndActivate();

      final current = (await PackageInfo.fromPlatform()).version;
      final minRequired = FirebaseRemoteConfig.instance
          .getString('min_required_version');

      final isForce = minRequired.isNotEmpty &&
          minRequired != '0.0.0' &&
          isLowerThan(current, minRequired);

      if (isForce) {
        if (Platform.isAndroid) {
          await _performAndroidImmediate();
        }
        action.value = UpdateAction.force;
        return UpdateAction.force;
      }

      if (Platform.isAndroid) {
        final result = await _checkAndroidOptional();
        action.value = result;
        return result;
      }

      action.value = UpdateAction.none;
      return UpdateAction.none;
    } catch (_) {
      action.value = UpdateAction.none;
      return UpdateAction.none;
    } finally {
      _checking = false;
    }
  }

  /// استدعاء يدوي من زر "تحديث الآن" — يتجاوز الـ throttle.
  Future<void> triggerAndroidUpdate() async {
    if (!Platform.isAndroid) return;
    await _performAndroidImmediate();
  }

  Future<void> _performAndroidImmediate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
      }
    } on PlatformException {
      await _openStore();
    }
  }

  Future<UpdateAction> _checkAndroidOptional() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        final availableCode = info.availableVersionCode;
        _lastAvailableVersionCode = availableCode;
        final skipped =
            _box.read<int?>(StorageKeys.skippedUpdateVersion);
        if (skipped != null && skipped == availableCode) {
          return UpdateAction.none;
        }
        return UpdateAction.optional;
      }
    } on PlatformException {
      return UpdateAction.none;
    }
    return UpdateAction.none;
  }

  Future<void> startFlexibleUpdate() async {
    try {
      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.success) {
        _showInstallSnackBar();
      }
    } on PlatformException {
      // update failed silently
    }
  }

  Future<void> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } on PlatformException {
      // update failed silently
    }
  }

  void skipOptional(int versionCode) {
    _box.write(StorageKeys.skippedUpdateVersion, versionCode);
    action.value = UpdateAction.none;
  }

  void _showInstallSnackBar() {
    final ctx = Get.context;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: const Text(UpdateStrings.updateReady),
        action: SnackBarAction(
          label: UpdateStrings.installNow,
          onPressed: () => completeFlexibleUpdate(),
        ),
      ),
    );
  }

  Future<void> _openStore() async {
    final packageName = (await PackageInfo.fromPlatform()).packageName;
    final marketUri = Uri.parse('market://details?id=$packageName');
    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri);
    } else {
      await launchUrl(
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName'),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
