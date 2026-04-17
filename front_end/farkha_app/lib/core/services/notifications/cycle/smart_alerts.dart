import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../notification_service.dart';

/// Smart alert thresholds for broiler cycles.
///
/// Fired immediately (not scheduled) when the user saves daily data
/// and the entered values exceed safety thresholds.
class SmartAlerts {
  // Notification IDs — must not conflict with any existing IDs
  static const int _mortalityDailyAlertId = 11001;
  static const int _mortalityCumulativeAlertId = 11002;
  static const int _fcrAlertId = 11003;

  /// Daily mortality threshold: ≥ 2 % of initial flock in one entry
  static const double _dailyMortalityThresholdPct = 0.02;

  /// Cumulative mortality threshold: ≥ 5 % of initial flock total
  static const double _cumulativeMortalityThresholdPct = 0.05;

  /// FCR threshold: > 2.2 is considered poor for standard broilers
  static const double _fcrWarningThreshold = 2.2;

  // ── Mortality ─────────────────────────────────────────────────────────

  /// Call after successfully saving a mortality entry.
  ///
  /// [newMortality]   — count entered in the current save action
  /// [totalMortality] — updated cumulative mortality after the save
  /// [chickCount]     — initial flock size at cycle start
  /// [cycleName]      — cycle name for the notification title
  static Future<void> checkMortalityAlert({
    required int newMortality,
    required int totalMortality,
    required int chickCount,
    required String cycleName,
  }) async {
    if (chickCount <= 0) return;
    if (!Get.isRegistered<NotificationService>()) return;

    final service = NotificationService.instance;
    final name = cycleName.isNotEmpty ? cycleName : 'الدورة الحالية';

    // 1. Daily entry alert
    final dailyPct = newMortality / chickCount;
    if (dailyPct >= _dailyMortalityThresholdPct) {
      final pctStr = (dailyPct * 100).toStringAsFixed(1);
      try {
        await service.showImmediateAlertNotification(
          id: _mortalityDailyAlertId,
          title: '$name: ⚠️ نفوق مرتفع اليوم',
          body:
              'تم تسجيل $newMortality وفاة في هذه المرة ($pctStr% من القطيع). '
              'تحقق من الحرارة والتهوية وصحة الطيور.',
          payload: {'type': 'smart_alert', 'alert': 'mortality_daily'},
        );
      } catch (e) {
        if (kDebugMode) debugPrint('SmartAlerts: daily mortality alert failed: $e');
      }
    }

    // 2. Cumulative alert (only if daily alert wasn't just fired to avoid double-buzz)
    final cumulativePct = totalMortality / chickCount;
    if (cumulativePct >= _cumulativeMortalityThresholdPct &&
        dailyPct < _dailyMortalityThresholdPct) {
      final pctStr = (cumulativePct * 100).toStringAsFixed(1);
      try {
        await service.showImmediateAlertNotification(
          id: _mortalityCumulativeAlertId,
          title: '$name: ⚠️ إجمالي النفوق تجاوز 5%',
          body:
              'إجمالي الوفيات وصل إلى $totalMortality طير ($pctStr%). '
              'راجع بروتوكول الرعاية والتغذية والصحة.',
          payload: {'type': 'smart_alert', 'alert': 'mortality_cumulative'},
        );
      } catch (e) {
        if (kDebugMode) debugPrint('SmartAlerts: cumulative mortality alert failed: $e');
      }
    }
  }

  // ── FCR ──────────────────────────────────────────────────────────────

  /// Call after successfully saving a feed consumption entry.
  ///
  /// [totalFeedKg]     — total feed consumed so far (kg)
  /// [latestWeightKg]  — most recent average weight entry (kg/bird)
  /// [survivingChicks] — initial count minus total mortality
  /// [cycleName]       — cycle name for the notification title
  static Future<void> checkFCRAlert({
    required double totalFeedKg,
    required double latestWeightKg,
    required int survivingChicks,
    required String cycleName,
  }) async {
    if (survivingChicks <= 0 || latestWeightKg <= 0 || totalFeedKg <= 0) return;
    if (!Get.isRegistered<NotificationService>()) return;

    final totalMeatKg = survivingChicks * latestWeightKg;
    final fcr = totalFeedKg / totalMeatKg;

    if (fcr > _fcrWarningThreshold) {
      final service = NotificationService.instance;
      final name = cycleName.isNotEmpty ? cycleName : 'الدورة الحالية';
      final fcrStr = fcr.toStringAsFixed(2);
      try {
        await service.showImmediateAlertNotification(
          id: _fcrAlertId,
          title: '$name: ⚠️ FCR مرتفع ($fcrStr)',
          body:
              'معامل التحويل الغذائي الحالي $fcrStr وهو أعلى من المعدل المثالي (2.2). '
              'راجع جودة العلف والاستهلاك اليومي ووزن الطيور.',
          payload: {'type': 'smart_alert', 'alert': 'fcr_high'},
        );
      } catch (e) {
        if (kDebugMode) debugPrint('SmartAlerts: FCR alert failed: $e');
      }
    }
  }
}
