import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constant/theme/colors.dart';
import '../../../core/class/status_request.dart';
import '../../../data/data_source/remote/cycle_feedback_data.dart';
import '../../view/widget/cycle_feedback/cycle_feedback_dialog.dart';

class CycleFeedbackController extends GetxController {
  final CycleFeedbackData cycleFeedbackData;

  CycleFeedbackController(this.cycleFeedbackData);

  int rating = 0;
  TextEditingController issueController = TextEditingController();
  TextEditingController suggestionController = TextEditingController();
  StatusRequest statusRequest = StatusRequest.none;
  String? validationError;

  final GetStorage _box = GetStorage();

  static const String _kFirstCycleOpen = 'cycle_fb_first_cycle_open';
  static const String _kLastShown = 'cycle_fb_last_shown';
  static const String _kCycleOpensSinceLastShown = 'cycle_fb_opens_since_last';

  static const Duration _firstDelay = Duration(days: 25);
  static const Duration _interval = Duration(days: 60);
  static const int _requiredOpens = 25;

  String? _appVersion;
  final String _platform = kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios');

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  void recordCycleOpen() {
    if (_box.read<String>(_kFirstCycleOpen) == null) {
      _box.write(_kFirstCycleOpen, DateTime.now().toIso8601String());
    }
    final count = _box.read<int>(_kCycleOpensSinceLastShown) ?? 0;
    _box.write(_kCycleOpensSinceLastShown, count + 1);
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
    } catch (_) {}
  }

  void setRating(int value) {
    rating = value;
    validationError = null;
    update();
  }

  Future<void> maybeShowDialog() async {
    if (!_shouldShow()) return;

    _box.write(_kLastShown, DateTime.now().toIso8601String());
    _box.write(_kCycleOpensSinceLastShown, 0);

    try {
      unawaited(Get.dialog<void>(
        const CycleFeedbackDialog(),
        barrierDismissible: true,
      ));
    } catch (e, stack) {
      try {
        unawaited(FirebaseCrashlytics.instance.recordError(e, stack));
      } catch (_) {}
    }
  }

  bool _shouldShow() {
    final opens = _box.read<int>(_kCycleOpensSinceLastShown) ?? 0;
    if (opens < _requiredOpens) return false;

    final firstOpenStr = _box.read<String>(_kFirstCycleOpen);
    if (firstOpenStr == null) return false;

    final firstOpen = DateTime.tryParse(firstOpenStr);
    if (firstOpen == null) return false;

    final now = DateTime.now();
    final lastShownStr = _box.read<String>(_kLastShown);

    if (lastShownStr == null) {
      return now.difference(firstOpen) >= _firstDelay;
    }

    final lastShown = DateTime.tryParse(lastShownStr);
    if (lastShown == null) return false;

    return now.difference(lastShown) >= _interval;
  }

  Future<void> submit() async {
    if (rating < 1) {
      validationError = 'اختَر عدد النجوم';
      statusRequest = StatusRequest.none;
      update();
      return;
    }

    validationError = null;
    statusRequest = StatusRequest.loading;
    update();

    try {
      final issue = issueController.text.trim();
      final suggestion = suggestionController.text.trim();

      final result = await cycleFeedbackData.submit(
        rating: rating,
        issue: issue.isEmpty ? null : issue,
        suggestion: suggestion.isEmpty ? null : suggestion,
        appVersion: _appVersion,
        platform: _platform,
      );

      result.fold(
        (failure) {
          statusRequest = failure;
          update();
        },
        (response) {
          statusRequest = StatusRequest.success;
          if (Get.isDialogOpen == true) {
            Get.back<void>();
          }
          if (!Get.testMode) {
            try {
              Get.snackbar(
                'شكراً لك',
                'شكراً لمشاركتنا رأيك',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryColor,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
            } catch (_) {}
          }
          update();
        },
      );
    } catch (e, stack) {
      try {
        unawaited(FirebaseCrashlytics.instance.recordError(e, stack));
      } catch (_) {}
      statusRequest = StatusRequest.serverFailure;
      update();
    }
  }

  void skip() {
    if (Get.isDialogOpen == true) {
      Get.back<void>();
    }
  }

  @override
  void onClose() {
    issueController.dispose();
    suggestionController.dispose();
    super.onClose();
  }
}
