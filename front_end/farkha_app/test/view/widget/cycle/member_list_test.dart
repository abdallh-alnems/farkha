import 'package:farkha_app/core/services/initialization.dart';
import 'package:farkha_app/logic/controller/cycle_controller.dart';
import 'package:farkha_app/view/widget/cycle/member_list_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/lifecycle.dart';
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
    when(() => mockMyServices.onStart).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(() => mockMyServices.onDelete).thenReturn(InternalFinalCallback<void>(callback: () {}));

    controller = CycleController(
      auth: mockAuth,
      cycleData: fakeCycleData,
      myServices: mockMyServices,
    );
    Get.put<CycleController>(controller);
    Get.put<MyServices>(mockMyServices);
  });

  tearDown(TestHarness.tearDownGetx);

  Future<void> pumpMemberList(WidgetTester tester) async {
    await TestHarness.pump(
      tester,
      SizedBox(
        width: 390,
        height: 844,
        child: SingleChildScrollView(child: const MemberListWidget()),
      ),
    );
  }

  testWidgets('يعرض عنوان أعضاء الدورة', (tester) async {
    controller.currentCycle.value = {
      'cycle_id': 1,
      'is_owner': true,
      'members': <dynamic>[],
    };

    await pumpMemberList(tester);

    expect(find.text('أعضاء الدورة'), findsOneWidget);
  });

  testWidgets('يعرض رسالة لا يوجد أعضاء عند قائمة فارغة', (tester) async {
    controller.currentCycle.value = {
      'cycle_id': 1,
      'is_owner': true,
      'members': <dynamic>[],
    };

    await pumpMemberList(tester);

    expect(find.text('لا يوجد أعضاء آخرين في هذه الدورة'), findsOneWidget);
  });

  testWidgets('لا أخطاء layout عند قائمة فارغة', (tester) async {
    controller.currentCycle.value = {
      'cycle_id': 1,
      'is_owner': true,
      'members': <dynamic>[],
    };

    await pumpMemberList(tester);

    expect(find.byType(MemberListWidget), findsOneWidget);
  });
}
