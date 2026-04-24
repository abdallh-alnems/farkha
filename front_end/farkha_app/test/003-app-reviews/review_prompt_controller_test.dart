import 'package:farkha_app/core/services/analytics_service.dart';
import 'package:farkha_app/logic/controller/review_prompt_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_harness.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late GetStorage storage;
  late ReviewPromptController controller;

  setUp(() async {
    TestHarness.setUpGetx();
    await TestHarness.ensureGetStorage();
    storage = await TestHarness.getStorage();
    await storage.erase();

    final analytics = MockAnalyticsService();
    when(() => analytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});
    Get.lazyPut<AnalyticsService>(() => analytics);

    controller = ReviewPromptController(storage: storage);
  });

  tearDown(() {
    Get.reset();
  });

  group('registerActivity', () {
    test('أول فتح: يضبط first_launch_at و unique_active_days_count = 1', () {
      controller.registerActivity();

      expect(storage.read<String>('first_launch_at'), isNotNull);
      expect(storage.read<int>('unique_active_days_count'), equals(1));
      expect(storage.read<String>('last_active_date'), isNotNull);
    });

    test('فتح في نفس اليوم: العدّاد لا يزيد', () {
      controller.registerActivity();
      final countAfterFirst = storage.read<int>('unique_active_days_count');

      controller.registerActivity();
      final countAfterSecond = storage.read<int>('unique_active_days_count');

      expect(countAfterFirst, equals(countAfterSecond));
    });

    test('فتح في يوم جديد: العدّاد يزيد بـ 1', () {
      controller.registerActivity();

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      storage.write('last_active_date', yesterdayKey);

      controller.registerActivity();

      expect(storage.read<int>('unique_active_days_count'), equals(2));
    });
  });

  group('shouldShowPrompt', () {
    test('يُرجع false إذا قيّم مؤخرًا (أقل من 60 يوم)', () async {
      _setupEligibleUser(storage);
      storage.write('review_prompt_dismissed_at',
          DateTime.now().subtract(const Duration(days: 10)).toIso8601String());

      expect(await controller.shouldShowPrompt(), isFalse);
    });

    test('يُرجع true إذا قيّم قبل أكثر من 60 يوم و unique_days >= 20', () async {
      _setupEligibleUser(storage);
      storage.write('unique_active_days_count', 20);
      storage.write('review_prompt_dismissed_at',
          DateTime.now().subtract(const Duration(days: 61)).toIso8601String());

      expect(await controller.shouldShowPrompt(), isTrue);
    });

    test('يُرجع false إذا لم تمض 30 يوم', () async {
      _setupEligibleUser(storage);
      storage.write(
          'first_launch_at', DateTime.now().toIso8601String());

      expect(await controller.shouldShowPrompt(), isFalse);
    });

    test('يُرجع false إذا unique_active_days_count < 10', () async {
      _setupEligibleUser(storage);
      storage.write('unique_active_days_count', 9);

      expect(await controller.shouldShowPrompt(), isFalse);
    });

    test('يُرجع true إذا كل الشروط محقّقة', () async {
      _setupEligibleUser(storage);

      expect(await controller.shouldShowPrompt(), isTrue);
    });

    test('يُرجع false إذا dismissed خلال آخر 60 يوم', () async {
      _setupEligibleUser(storage);
      storage.write('review_prompt_dismissed_at',
          DateTime.now().subtract(const Duration(days: 5)).toIso8601String());

      expect(await controller.shouldShowPrompt(), isFalse);
    });

    test('يُرجع true إذا dismissed قبل أكثر من 60 يوم و unique_days >= 20', () async {
      _setupEligibleUser(storage);
      storage.write('unique_active_days_count', 20);
      storage.write('review_prompt_dismissed_at',
          DateTime.now().subtract(const Duration(days: 61)).toIso8601String());

      expect(await controller.shouldShowPrompt(), isTrue);
    });

    test('يُرجع false إذا dismissed قبل أكثر من 60 يوم لكن unique_days < 20', () async {
      _setupEligibleUser(storage);
      storage.write('unique_active_days_count', 15);
      storage.write('review_prompt_dismissed_at',
          DateTime.now().subtract(const Duration(days: 61)).toIso8601String());

      expect(await controller.shouldShowPrompt(), isFalse);
    });

    test('يُرجع false إذا لا يوجد first_launch_at', () async {
      expect(await controller.shouldShowPrompt(), isFalse);
    });
  });

  group('markRated', () {
    test('يضبط review_prompt_dismissed_at', () {
      controller.markRated();
      expect(storage.read<String>('review_prompt_dismissed_at'), isNotNull);
    });
  });

  group('markDismissed', () {
    test('يضبط review_prompt_dismissed_at', () {
      controller.markDismissed();
      expect(storage.read<String>('review_prompt_dismissed_at'), isNotNull);
    });
  });
}

void _setupEligibleUser(GetStorage storage) {
  storage.write('first_launch_at',
      DateTime.now().subtract(const Duration(days: 31)).toIso8601String());
  storage.write('unique_active_days_count', 12);
  storage.write('last_active_date', _todayKey());
}

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
