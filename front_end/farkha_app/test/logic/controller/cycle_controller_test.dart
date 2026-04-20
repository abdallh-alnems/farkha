import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/core/services/initialization.dart';
import 'package:farkha_app/logic/controller/cycle_controller.dart';
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
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late FakeCycleData fakeCycleData;
  late MockMyServices mockMyServices;

  setUp(() async {
    TestHarness.setUpGetx();
    await TestHarness.ensureGetStorage();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    fakeCycleData = FakeCycleData();
    mockMyServices = MockMyServices();

    final storage = await TestHarness.getStorage();
    storage.remove('cycles');
    storage.remove('deleted_cycles');
    when(() => mockMyServices.getStorage).thenReturn(storage);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.getIdToken()).thenAnswer((_) async => 'fake-token');
  });

  tearDown(TestHarness.tearDownGetx);

  group('CycleController DI', () {
    test('يقبل cycleData مخصّص', () {
      final ctrl = CycleController(cycleData: fakeCycleData);
      expect(ctrl, isNotNull);
    });

    test('يقبل auth مخصّص', () {
      final ctrl = CycleController(auth: mockAuth);
      expect(ctrl, isNotNull);
    });

    test('يقبل myServices مخصّص', () {
      final ctrl = CycleController(myServices: mockMyServices);
      expect(ctrl, isNotNull);
    });

    test('يعمل بدون أي parameters (production path)', () {
      final ctrl = CycleController();
      expect(ctrl, isNotNull);
    });
  });

  group('CycleController state', () {
    test('cycles تبدأ كقائمة فارغة', () {
      final ctrl = CycleController(
        auth: mockAuth,
        cycleData: fakeCycleData,
        myServices: mockMyServices,
      );
      expect(ctrl.cycles, isEmpty);
    });

    test('currentCycle تبدأ كخريطة فارغة', () {
      final ctrl = CycleController(
        auth: mockAuth,
        cycleData: fakeCycleData,
        myServices: mockMyServices,
      );
      expect(ctrl.currentCycle, isEmpty);
    });
  });

  group('CycleController.fetchCycles', () {
    test('يتعامل مع فشل الخادم', () async {
      fakeCycleData.when('getCycles', const Left(StatusRequest.serverFailure));

      final ctrl = CycleController(
        auth: mockAuth,
        cycleData: fakeCycleData,
        myServices: mockMyServices,
      );
      Get.put<CycleController>(ctrl);

      await ctrl.fetchCyclesFromServer().catchError((_) {});

      expect(ctrl.cycles, isEmpty);
    });

    test('يتعامل مع فشل الاتصال', () async {
      fakeCycleData.when('getCycles', const Left(StatusRequest.offlineFailure));

      final ctrl = CycleController(
        auth: mockAuth,
        cycleData: fakeCycleData,
        myServices: mockMyServices,
      );
      Get.put<CycleController>(ctrl);

      await ctrl.fetchCyclesFromServer().catchError((_) {});

      expect(ctrl.cycles, isEmpty);
    });
  });
}
