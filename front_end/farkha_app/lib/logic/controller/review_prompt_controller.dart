import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/services/analytics_service.dart';
import '../../view/widget/app_review/review_prompt_dialog.dart';

class ReviewPromptController extends GetxController {
  static const String _kFirstLaunch = 'first_launch_at';
  static const String _kLastActive = 'last_active_date';
  static const String _kUniqueDaysCount = 'unique_active_days_count';
  static const String _kDismissedAt = 'review_prompt_dismissed_at';
  static const String _kHasRatedLocal = 'user_has_rated_local';

  final GetStorage _box;

  ReviewPromptController({GetStorage? storage})
      : _box = storage ?? GetStorage();

  void registerActivity() {
    final now = DateTime.now();
    final today = _dateKey(now);

    final firstLaunch = _box.read<String>(_kFirstLaunch);
    if (firstLaunch == null) {
      _box.write(_kFirstLaunch, now.toIso8601String());
      _box.write(_kUniqueDaysCount, 1);
      _box.write(_kLastActive, today);
      return;
    }

    final lastActive = _box.read<String>(_kLastActive);
    if (lastActive != null && lastActive != today) {
      final currentCount = _box.read<int>(_kUniqueDaysCount) ?? 1;
      _box.write(_kUniqueDaysCount, currentCount + 1);
      _box.write(_kLastActive, today);
    }
  }

  void markRated() {
    _box.write(_kHasRatedLocal, true);
  }

  void markDismissed() {
    _box.write(_kDismissedAt, DateTime.now().toIso8601String());
  }

  void acceptPrompt() {
    markRated();
  }

  Future<bool> shouldShowPrompt() async {
    final hasRated = _box.read<bool>(_kHasRatedLocal) ?? false;
    if (hasRated) return false;

    final firstLaunchStr = _box.read<String>(_kFirstLaunch);
    if (firstLaunchStr == null) return false;
    final firstLaunch = DateTime.tryParse(firstLaunchStr);
    if (firstLaunch == null) return false;

    final daysSinceInstall = DateTime.now().difference(firstLaunch).inDays;
    if (daysSinceInstall < 30) return false;

    final uniqueDays = _box.read<int>(_kUniqueDaysCount) ?? 0;
    if (uniqueDays < 10) return false;

    final dismissedAtStr = _box.read<String>(_kDismissedAt);
    if (dismissedAtStr != null) {
      final dismissedAt = DateTime.tryParse(dismissedAtStr);
      if (dismissedAt != null) {
        final daysSinceDismiss = DateTime.now().difference(dismissedAt).inDays;
        if (daysSinceDismiss < 30) return false;
      }
    }

    return true;
  }

  Future<void> maybeShowPrompt(BuildContext context) async {
    if (Get.isDialogOpen == true) return;
    if (!context.mounted) return;

    final shouldShow = await shouldShowPrompt();
    if (!shouldShow) return;
    if (!context.mounted) return;

    final analytics = Get.find<AnalyticsService>();
    await analytics.logEvent(name: AnalyticsService.reviewPromptShown);

    if (context.mounted) {
      unawaited(showDialog<void>(
        context: context,
        builder: (_) => const ReviewPromptDialog(),
      ));
    }
  }

  String _dateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
