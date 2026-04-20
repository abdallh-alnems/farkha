import 'package:farkha_app/core/services/initialization.dart';
import 'package:farkha_app/logic/controller/cycle_controller.dart';
import 'package:farkha_app/logic/controller/cycle_sales_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_cycle_data.dart';
import '../../helpers/test_harness.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockMyServices extends Mock implements MyServices {}

void main() {
  late FakeCycleData fakeCycleData;
  late CycleSalesController controller;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockMyServices mockMyServices;

  setUpAll(() async {
    TestHarness.setUpGetx();
    await TestHarness.ensureGetStorage();
  });

  setUp(() async {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    fakeCycleData = FakeCycleData();
    mockMyServices = MockMyServices();

    final storage = await TestHarness.getStorage();
    when(() => mockMyServices.getStorage).thenReturn(storage);

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.getIdToken()).thenAnswer((_) async => 'fake-token');

    final fakeCycleCtrl = CycleController(
      auth: mockAuth,
      cycleData: fakeCycleData,
      myServices: mockMyServices,
    );
    fakeCycleCtrl.currentCycle.value = {
      'cycle_id': 1,
      'id': '1',
      'name': 'دورة اختبارية',
      'sales': <dynamic>[],
      'total_sales': '0',
    };
    Get.put<CycleController>(fakeCycleCtrl);

    controller = CycleSalesController(
      cycleData: fakeCycleData,
      cycleController: fakeCycleCtrl,
      auth: mockAuth,
      myServices: mockMyServices,
    );
    Get.put<CycleSalesController>(controller);
  });

  tearDown(TestHarness.tearDownGetx);

  group('CycleSalesController DI', () {
    test('يقبل cycleData مخصّص', () {
      final ctrl = CycleSalesController(cycleData: fakeCycleData);
      expect(ctrl, isNotNull);
    });

    test('يقبل auth مخصّص', () {
      final ctrl = CycleSalesController(auth: mockAuth);
      expect(ctrl, isNotNull);
    });

    test('يعمل بدون أي parameters', () {
      final ctrl = CycleSalesController();
      expect(ctrl, isNotNull);
    });
  });

  group('CycleSalesController state', () {
    test('المبيعات تبدأ كقائمة فارغة', () {
      expect(controller.sales, isEmpty);
    });

    test('إجمالي المبيعات يبدأ بصفر', () {
      expect(controller.totalSales.value, 0.0);
    });
  });
}
