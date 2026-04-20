import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/core/services/initialization.dart';
import 'package:farkha_app/logic/controller/cycle_controller.dart';
import 'package:farkha_app/view/screen/cycle/cycle_history_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_cycle_data.dart';
import '../../../helpers/test_harness.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockMyServices extends Mock implements MyServices {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late FakeCycleData fakeCycleData;
  late MockMyServices mockMyServices;
  late CycleController controller;

  setUp(() async {
    TestHarness.setUpGetx();
    await TestHarness.ensureGetStorage();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    fakeCycleData = FakeCycleData();
    mockMyServices = MockMyServices();

    final storage = await TestHarness.getStorage();
    when(() => mockMyServices.getStorage).thenReturn(storage);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.getIdToken()).thenAnswer((_) async => 'fake-token');

    controller = CycleController(
      auth: mockAuth,
      cycleData: fakeCycleData,
      myServices: mockMyServices,
    );
    Get.put<CycleController>(controller);
  });

  tearDown(TestHarness.tearDownGetx);

  Future<void> pumpWithOverflowSuppression(
    WidgetTester tester,
    Widget widget,
  ) async {
    final originalOnError = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!details.exceptionAsString().contains('overflowed') &&
          !details.exceptionAsString().contains('RenderFlex')) {
        originalOnError(details);
      }
    };
    try {
      await TestHarness.pump(tester, widget);
    } finally {
      FlutterError.onError = originalOnError;
    }
  }

  testWidgets('يعرض حالة لا توجد بيانات عند status فارغ', (tester) async {
    controller.historicCycleStatus.value = StatusRequest.none;
    controller.historicCycleDetails.clear();

    await pumpWithOverflowSuppression(
      tester,
      const CycleHistoryDetailsScreen(),
    );

    expect(find.text('لا توجد بيانات متاحة'), findsOneWidget);
  });

  testWidgets('يعرض عنوان التقرير عند نجاح التحميل', (tester) async {
    controller.historicCycleStatus.value = StatusRequest.success;
    controller.historicCycleDetails.value = {
      'name': 'دورة اختبارية',
      'start_date': '2026-01-01',
      'end_date': '2026-02-01',
      'chick_count': 1000,
      'mortality': 50,
      'remaining': 950,
      'total_feed': '500',
      'average_weight': '2.5',
      'total_expenses': '10000',
      'total_sales': '15000',
      'net_profit': '5000',
      'feed_cost': '3000',
      'chick_cost': '2000',
      'fcr': '1.8',
      'total_meat': '2375',
      'space': '100',
    };

    await pumpWithOverflowSuppression(
      tester,
      const CycleHistoryDetailsScreen(),
    );

    expect(find.text('تقرير الدورة التفصيلي'), findsOneWidget);
  });

  testWidgets('اتجاه RTL محفوظ', (tester) async {
    controller.historicCycleStatus.value = StatusRequest.none;

    await TestHarness.pump(
      tester,
      const CycleHistoryDetailsScreen(),
    );

    final dir = tester.widgetList<Directionality>(
      find.byType(Directionality),
    );
    expect(dir.any((d) => d.textDirection == TextDirection.rtl), isTrue);
  });
}
