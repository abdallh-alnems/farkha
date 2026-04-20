import 'package:farkha_app/core/services/initialization.dart';
import 'package:farkha_app/logic/controller/cycle_controller.dart';
import 'package:farkha_app/logic/controller/cycle_notes_controller.dart';
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
  late CycleNotesController controller;
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
      'name': 'دورة اختبارية',
      'notes': <dynamic>[],
    };
    Get.put<CycleController>(fakeCycleCtrl);

    controller = CycleNotesController(
      cycleData: fakeCycleData,
      auth: mockAuth,
      myServices: mockMyServices,
    );
    Get.put<CycleNotesController>(controller);
  });

  tearDown(TestHarness.tearDownGetx);

  group('CycleNotesController DI', () {
    test('يقبل cycleData مخصّص', () {
      final ctrl = CycleNotesController(cycleData: fakeCycleData);
      expect(ctrl, isNotNull);
    });

    test('يقبل auth مخصّص', () {
      final ctrl = CycleNotesController(auth: mockAuth);
      expect(ctrl, isNotNull);
    });

    test('يعمل بدون أي parameters', () {
      final ctrl = CycleNotesController();
      expect(ctrl, isNotNull);
    });
  });

  group('CycleNotesController state', () {
    test('الملاحظات تبدأ كقائمة فارغة', () {
      expect(controller.notes, isEmpty);
    });
  });
}
