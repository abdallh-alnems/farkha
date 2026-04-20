import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/core/services/initialization.dart';
import 'package:farkha_app/data/data_source/remote/auth_data/login_data.dart';
import 'package:farkha_app/logic/controller/auth/login_controller.dart';
import 'package:farkha_app/logic/controller/cycle_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/lifecycle.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fake_cycle_data.dart';
import '../helpers/test_harness.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockMyServices extends Mock implements MyServices {}

class FakeLoginDataForIntegration implements LoginData {
  Either<StatusRequest, Map<String, dynamic>>? response;

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> login(String token) async =>
      response ?? const Left(StatusRequest.serverFailure);
}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockMyServices mockMyServices;
  late FakeCycleData fakeCycleData;

  setUp(() async {
    TestHarness.setUpGetx();
    await TestHarness.ensureGetStorage();

    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockMyServices = MockMyServices();
    fakeCycleData = FakeCycleData();

    final storage = await TestHarness.getStorage();
    when(() => mockMyServices.getStorage).thenReturn(storage);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.getIdToken()).thenAnswer((_) async => 'fake-token');
    when(() => mockMyServices.onStart).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(() => mockMyServices.onDelete).thenReturn(InternalFinalCallback<void>(callback: () {}));
  });

  tearDown(TestHarness.tearDownGetx);

  group('Controller wiring with fakes', () {
    test('LoginController + CycleController مسجّلين مع fakes', () async {
      fakeCycleData.when('getCycles', Right<StatusRequest, Map<String, dynamic>>({
        'status': 'success',
        'data': {
          'cycles': [
            {'cycle_id': 1, 'name': 'دورة اختبارية', 'status': 'active', 'role': 'owner'},
          ],
        },
      }));

      Get.put<MyServices>(mockMyServices);
      final fakeLoginData = FakeLoginDataForIntegration();
      fakeLoginData.response = Right<StatusRequest, Map<String, dynamic>>({
        'status': 'success',
        'success': true,
        'token': 'fake-jwt-token',
      });

      Get.put<LoginController>(
        LoginController(auth: mockAuth, loginData: fakeLoginData),
        permanent: true,
      );
      Get.put<CycleController>(
        CycleController(
          auth: mockAuth,
          cycleData: fakeCycleData,
          myServices: mockMyServices,
        ),
      );

      expect(Get.find<LoginController>(), isNotNull);
      expect(Get.find<CycleController>(), isNotNull);
      expect(Get.find<LoginController>().isLoggedIn.value, isFalse);
    });

    test('CycleController.fetchCyclesFromServer يملأ cycles من FakeCycleData', () async {
      fakeCycleData.when('getCycles', Right<StatusRequest, Map<String, dynamic>>({
        'status': 'success',
        'data': {
          'cycles': [
            {'cycle_id': 1, 'name': 'دورة اختبارية'},
          ],
        },
      }));

      Get.put<MyServices>(mockMyServices);
      Get.put<CycleController>(
        CycleController(
          auth: mockAuth,
          cycleData: fakeCycleData,
          myServices: mockMyServices,
        ),
      );

      final cycleCtrl = Get.find<CycleController>();
      await cycleCtrl.fetchCyclesFromServer();

      expect(cycleCtrl.cycles.isNotEmpty, isTrue);
    });

    test('FakeCycleData.createCycle يُرجع cycle_id', () async {
      fakeCycleData.when('createCycle', Right<StatusRequest, Map<String, dynamic>>({
        'status': 'success',
        'data': {'cycle_id': 2},
      }));

      final result = await fakeCycleData.createCycle(
        token: 'fake-token',
        name: 'دورة جديدة',
        chickCount: 500,
        space: 50.0,
        startDateRaw: '2026-01-15',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (data) => expect(data['data']['cycle_id'], 2),
      );
    });

    test('FakeLoginData مع serverFailure لا يغيّر isLoggedIn', () async {
      final fakeLoginData = FakeLoginDataForIntegration();
      fakeLoginData.response = const Left(StatusRequest.serverFailure);

      Get.put<LoginController>(
        LoginController(auth: mockAuth, loginData: fakeLoginData),
        permanent: true,
      );

      expect(Get.find<LoginController>().isLoggedIn.value, isFalse);
    });
  });
}
