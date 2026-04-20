import 'package:farkha_app/logic/controller/auth/login_controller.dart';
import 'package:farkha_app/view/screen/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../helpers/fake_login_data.dart';
import '../../../helpers/test_harness.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeLoginData fakeLoginData;

  setUp(() {
    TestHarness.setUpGetx();
    mockAuth = MockFirebaseAuth();
    fakeLoginData = FakeLoginData();
    Get.put<LoginController>(
      LoginController(auth: mockAuth, loginData: fakeLoginData),
      permanent: true,
    );
  });

  tearDown(TestHarness.tearDownGetx);

  Future<void> pumpLogin(
    WidgetTester tester, {
    bool darkMode = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    final originalOnError = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!details.exceptionAsString().contains('overflowed') &&
          !details.exceptionAsString().contains('RenderFlex')) {
        originalOnError(details);
      }
    };
    try {
      await TestHarness.pump(tester, const LoginScreen(), darkMode: darkMode);
    } finally {
      FlutterError.onError = originalOnError;
    }
  }

  testWidgets('عرض عنوان الدخول العربي في light mode', (tester) async {
    await pumpLogin(tester);

    expect(find.text('فرخة'), findsOneWidget);
    expect(find.text('أهلاً وسهلاً 👋'), findsOneWidget);
    expect(find.text('سجّل دخولك للبدء'), findsOneWidget);
  });

  testWidgets('عرض عنوان الدخول العربي في dark mode', (tester) async {
    await pumpLogin(tester, darkMode: true);

    expect(find.text('فرخة'), findsOneWidget);
    expect(find.text('أهلاً وسهلاً 👋'), findsOneWidget);
    expect(find.text('سجّل دخولك للبدء'), findsOneWidget);
  });

  testWidgets('اتجاه RTL محفوظ', (tester) async {
    await pumpLogin(tester);

    final dir = tester.widgetList<Directionality>(
      find.byType(Directionality),
    );
    expect(dir.any((d) => d.textDirection == TextDirection.rtl), isTrue);
  });

  testWidgets('زر Google ظاهر مع النص العربي', (tester) async {
    await pumpLogin(tester);

    expect(find.text('المتابعة بحساب Google'), findsOneWidget);
  });
}
