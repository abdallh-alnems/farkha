import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/constant/storage_keys.dart';
import '../../core/services/test_mode_manager.dart';
import '../../view/widget/app_review/app_review_dialog.dart';
import '../../../logic/bindings/app_review_binding.dart';

class ReviewPromptController extends GetxController {
  final GetStorage _box;

  ReviewPromptController({GetStorage? storage})
      : _box = storage ?? GetStorage();

  void registerActivity() {
    final now = DateTime.now();
    final today = _dateKey(now);

    final firstLaunch = _box.read<String>(StorageKeys.firstLaunchAt);
    if (firstLaunch == null) {
      _box.write(StorageKeys.firstLaunchAt, now.toIso8601String());
      _box.write(StorageKeys.uniqueActiveDaysCount, 1);
      _box.write(StorageKeys.lastActiveDate, today);
      return;
    }

    final lastActive = _box.read<String>(StorageKeys.lastActiveDate);
    if (lastActive == null || lastActive != today) {
      final currentCount = _box.read<int>(StorageKeys.uniqueActiveDaysCount) ?? 1;
      _box.write(StorageKeys.uniqueActiveDaysCount, currentCount + 1);
      _box.write(StorageKeys.lastActiveDate, today);
    }
  }

  void markRated() {
    _box.write(StorageKeys.reviewPromptDismissedAt, DateTime.now().toIso8601String());
  }

  void markDismissed() {
    _box.write(StorageKeys.reviewPromptDismissedAt, DateTime.now().toIso8601String());
  }

  void acceptPrompt() {
    markRated();
  }

  Future<bool> shouldShowPrompt() async {
    if (TestModeManager.shouldAlwaysShowReviewPrompt) return true;

    final firstLaunch = _box.read<String>(StorageKeys.firstLaunchAt);
    if (firstLaunch == null) return false;

    final uniqueDays = _box.read<int>(StorageKeys.uniqueActiveDaysCount) ?? 0;
    if (uniqueDays < 10) return false;

    final firstLaunchDate = DateTime.parse(firstLaunch);
    final daysSinceInstall = DateTime.now().difference(firstLaunchDate).inDays;
    if (daysSinceInstall < 30) return false;

    final dismissedAt = _box.read<String>(StorageKeys.reviewPromptDismissedAt);
    final isRepeatPrompt = dismissedAt != null;
    if (isRepeatPrompt) {
      final dismissedDate = DateTime.parse(dismissedAt);
      final daysSinceDismiss = DateTime.now().difference(dismissedDate).inDays;
      if (daysSinceDismiss < 60) return false;
      if (uniqueDays < 20) return false;
    }

    return true;
  }

  Future<void> maybeShowPrompt(BuildContext context) async {
    if (Get.isDialogOpen == true) return;
    if (!context.mounted) return;

    final shouldShow = await shouldShowPrompt();
    if (!shouldShow) return;
    if (!context.mounted) return;

    if (context.mounted) {
      AppReviewBinding().dependencies();
      unawaited(showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AppReviewDialog(autoPrompted: true),
      ));
    }
  }

  String _dateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
