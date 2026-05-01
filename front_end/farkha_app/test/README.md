# دليل الاختبارات — تطبيق فرخة

## تشغيل الاختبارات

```bash
cd front_end/farkha_app

# كل الاختبارات
flutter test

# اختبار ملف محدّد
flutter test test/logic/controller/cycle_controller_test.dart

# اختبار مع إخراج verbose
flutter test --reporter expanded

# اختبارات unit فقط
flutter test test/logic/ test/data/

# اختبارات widget فقط
flutter test test/view/

# اختبارات الربط (integration wiring)
flutter test test/integration/
```

## بنية المجلدات

```text
test/
├── helpers/          # Fakes, mocks, harness مشتركة
│   ├── fake_crud.dart
│   ├── mock_firebase_auth.dart
│   ├── fake_login_data.dart
│   ├── fake_cycle_data.dart
│   ├── fixtures.dart
│   └── test_harness.dart
├── logic/controller/ # Unit tests لـ controllers
├── data/data_source/ # Data source wiring tests
├── view/             # Widget tests
│   ├── screen/
│   └── widget/
└── integration/      # Integration wiring tests
```

## كتابة اختبار جديد لـ controller

1. أضف optional constructor params في الـ controller (إن لم تكن موجودة)
2. أنشئ `test/logic/controller/<name>_controller_test.dart`
3. استخدم `FakeCycleData` أو `FakeLoginData` + `MockFirebaseAuth`
4. اكتب groups لكل method: نجاح، فشل خادم، فشل اتصال
5. `flutter test test/logic/controller/<name>_controller_test.dart`

## كتابة widget test جديد

1. أنشئ ملف اختبار في `test/view/` يتبع نفس مسار `lib/view/`
2. استخدم `TestHarness.pump(tester, widget)` للتهيئة
3. للشاشات المعقّدة التي تُنتج overflow errors، استخدم overflow suppression
4. تأكّد من فحص النصوص العربية و RTL

## قواعد ذهبية

- لا شبكة حقيقية — `FakeCycleData` / `FakeCrud` فقط
- لا `Firebase.initializeApp` — MockFirebaseAuth بدلاً منه
- `tearDown` يُشغّل `Get.reset()` لمنع تسرّب الحالة
- `setUp` يُشغّل `TestHarness.setUpGetx()` لتفعيل `Get.testMode`
- النصوص في assertions عربية
- كل اختبار deterministic — لا `DateTime.now()` مباشر

## CI

`.github/workflows/flutter_ci.yaml` يُشغّل `flutter analyze && flutter test` عند كل PR تلقائياً.
