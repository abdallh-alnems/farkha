import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/data/data_source/remote/cycle_feedback_data.dart';
import 'package:farkha_app/logic/controller/cycle_feedback_controller.dart';
import 'package:farkha_app/view/widget/cycle_feedback/cycle_feedback_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_harness.dart';

class MockCycleFeedbackData extends Mock implements CycleFeedbackData {}

void main() {
  late MockCycleFeedbackData mockData;
  late CycleFeedbackController controller;

  setUp(() {
    TestHarness.setUpGetx();

    mockData = MockCycleFeedbackData();
    controller = CycleFeedbackController(mockData);
    Get.put<CycleFeedbackController>(controller);
  });

  tearDown(() {
    TestHarness.tearDownGetx();
  });

  Future<void> pumpDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Get.dialog<void>(const CycleFeedbackDialog());
                },
                child: Text('Show'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
  }

  group('star interaction', () {
    testWidgets('tapping 5th star fills 1..5 stars and shows ممتاز',
        (tester) async {
      await pumpDialog(tester);

      final stars = find.byIcon(Icons.star_outline_rounded);
      expect(stars, findsNWidgets(5));

      await tester.tap(stars.last);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.text('ممتاز'), findsOneWidget);
    });

    testWidgets('tapping 4th star fills 1..4 stars and shows جيد',
        (tester) async {
      await pumpDialog(tester);

      final stars = find.byIcon(Icons.star_outline_rounded);
      await tester.tap(stars.at(3));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.text('جيد'), findsOneWidget);
    });
  });

  group('validation', () {
    testWidgets('submit with 0 stars shows Arabic validation', (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.text('إرسال'));
      await tester.pumpAndSettle();

      expect(find.text('اختَر عدد النجوم'), findsOneWidget);
    });

    testWidgets('submit with 0 stars does not close dialog', (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.text('إرسال'));
      await tester.pumpAndSettle();

      expect(find.text('كيف كانت تجربتك مع دورتك؟'), findsOneWidget);
    });
  });

  group('text fields', () {
    testWidgets('both text fields are present with hints', (tester) async {
      await pumpDialog(tester);

      expect(find.text('عندك مشكلة أو ملاحظة؟'), findsOneWidget);
      expect(find.text('ميزة تتمنى نضيفها؟'), findsOneWidget);
    });
  });

  group('skip buttons', () {
    testWidgets('tapping تخطي closes dialog', (tester) async {
      await pumpDialog(tester);

      expect(find.text('تخطي'), findsOneWidget);

      await tester.tap(find.text('تخطي'));
      await tester.pumpAndSettle();

      expect(find.text('كيف كانت تجربتك مع دورتك؟'), findsNothing);
    });

    testWidgets('tapping × closes dialog', (tester) async {
      await pumpDialog(tester);

      final closeBtn = find.byIcon(Icons.close);
      expect(closeBtn, findsOneWidget);

      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.text('كيف كانت تجربتك مع دورتك؟'), findsNothing);
    });
  });

  group('RTL layout', () {
    testWidgets('renders inside RTL directionality', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => GetMaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      Get.dialog<void>(const CycleFeedbackDialog());
                    },
                    child: Text('Show'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('كيف كانت تجربتك مع دورتك؟'), findsOneWidget);
      expect(find.text('عندك مشكلة أو ملاحظة؟'), findsOneWidget);
      expect(find.text('ميزة تتمنى نضيفها؟'), findsOneWidget);
    });
  });

  group('error state', () {
    testWidgets('shows Arabic error when offlineFailure', (tester) async {
      controller.rating = 3;
      controller.statusRequest = StatusRequest.offlineFailure;
      controller.update();

      await pumpDialog(tester);

      expect(find.text('تعذّر إرسال التقييم، تحقّق من الاتصال'),
          findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('shows Arabic error when serverFailure', (tester) async {
      controller.rating = 3;
      controller.statusRequest = StatusRequest.serverFailure;
      controller.update();

      await pumpDialog(tester);

      expect(find.text('حدث خطأ، حاول مرة أخرى'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('stars preserved during error state', (tester) async {
      controller.rating = 3;
      controller.statusRequest = StatusRequest.offlineFailure;
      controller.update();

      await pumpDialog(tester);

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    });
  });

  group('loading state', () {
    testWidgets('submit button shows spinner when loading', (tester) async {
      controller.rating = 3;
      controller.statusRequest = StatusRequest.loading;
      controller.update();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => GetMaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Get.dialog<void>(const CycleFeedbackDialog());
                  },
                  child: Text('Show'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Show'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
