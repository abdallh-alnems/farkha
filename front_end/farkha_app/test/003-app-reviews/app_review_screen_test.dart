import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/data/data_source/remote/app_review_data.dart';
import 'package:farkha_app/logic/controller/app_review_controller.dart';
import 'package:farkha_app/view/screen/app_review_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_harness.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockAppReviewData extends Mock implements AppReviewData {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockAppReviewData mockReviewData;

  setUp(() {
    TestHarness.setUpGetx();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockReviewData = MockAppReviewData();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.getIdToken()).thenAnswer((_) async => 'fake-token');

    when(() => mockReviewData.fetchMine(token: any(named: 'token')))
        .thenAnswer((_) async => {
              'status': 'success',
              'data': {'review': null}
            });
  });

  tearDown(TestHarness.tearDownGetx);

  Future<void> pumpScreen(WidgetTester tester) async {
    final controller = AppReviewController(
      mockReviewData,
      auth: mockAuth,
    );
    Get.put<AppReviewController>(controller);

    await TestHarness.pump(tester, const AppReviewScreen());
    await tester.pumpAndSettle();
  }

  group('AppReviewScreen widgets', () {
    testWidgets('يعرض 5 نجوم', (tester) async {
      await pumpScreen(tester);

      final stars = find.byIcon(Icons.star_border);
      expect(stars, findsNWidgets(5));
    });

    testWidgets('الضغط على النجمة الرابعة يجعل 4 نجوم مختارة',
        (tester) async {
      await pumpScreen(tester);

      final stars = find.byIcon(Icons.star_border);
      await tester.tap(stars.at(3));
      await tester.pumpAndSettle();

      final filledStars = find.byIcon(Icons.star);
      expect(filledStars, findsNWidgets(4));
    });

    testWidgets('زر الإرسال موجود', (tester) async {
      await pumpScreen(tester);

      expect(find.text('إرسال'), findsOneWidget);
    });

    testWidgets('زر الإرسال يظهر بعد التحميل', (tester) async {
      await pumpScreen(tester);

      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
