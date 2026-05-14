# Farkha App — تطبيق إدارة مزارع الدواجن

تطبيق Flutter لإدارة مزارع الدواجن، بواجهة عربية RTL ودعم Android و iOS.

> **Version:** 6.4.1+40 · **Flutter:** 3.7.2+ · **Dart:** 3.7.2+

---

## نظرة عامة

Farkha يساعد مربّي الدواجن على متابعة دورات الإنتاج، تسجيل الأوزان والاستهلاك والنفوق والمصاريف، الاطلاع على أسعار السوق اليومية، استخدام أدوات حسابية للمزرعة، وقراءة المقالات الزراعية. يتزامن مع Backend مبني على PHP REST API.

## الميزات

### إدارة الدورات
- تسجيل بيانات يومية: وزن، علف، نفوق، مصاريف، مبيعات
- إضافة أعضاء للدورة بأدوار مختلفة (`MembersTab`)
- ملاحظات مخصّصة لكل دورة
- تصدير تقارير PDF و Excel
- دراسات الجدوى وحساب الربحية
- تقييم الدورة بعد انتهائها (`cycle_feedbacks`)

### السوق والمحتوى
- أسعار السوق اليومية للدواجن
- مقالات زراعية وأخبار
- جدول التحصينات والأمراض

### المصادقة والحساب
- Firebase Auth + Google Sign-In + Sign in with Apple
- التحقق برقم الهاتف عبر OTP (Spec 002)
- حذف الحساب وتحديث البيانات

### تجربة المستخدم
- واجهة عربية RTL كاملة
- وضع Dark/Light عبر `DarkLightService`
- شاشات Onboarding للمستخدم الجديد
- تصميم responsive عبر `flutter_screenutil`
- خط Cairo
- Tutorial Coach Mark لإرشاد المستخدمين
- تقييم التطبيق عبر `rate_my_app` و `app_reviews` المخصّص

### التكاملات
- Firebase Messaging (FCM) + إشعارات محلية (`flutter_local_notifications`)
- Deep Links عبر `app_links`
- Firebase Remote Config للتحكم الديناميكي بالميزات
- Firebase Crashlytics و Analytics
- Firebase App Check
- Geolocation + Geocoding للموقع الجغرافي
- Google Mobile Ads (Android فقط — مُعطّل على iOS)
- مشاركة المحتوى عبر `share_plus`
- جهات الاتصال عبر `flutter_contacts`

---

## Tech Stack

| الفئة | الحزمة |
|------|--------|
| State Management | `get: ^4.7.2` (GetX) |
| Local Storage | `get_storage: ^2.1.1` |
| HTTP | `http: ^1.3.0` (مغلّفة في `core/class/crud.dart`) |
| Env | `flutter_dotenv: ^6.0.0` |
| Firebase Core | `firebase_core: ^4.2.1` |
| Auth | `firebase_auth: ^6.1.2` + `google_sign_in: ^7.2.0` + `sign_in_with_apple: ^8.0.0` |
| Messaging | `firebase_messaging: ^16.0.2` |
| Crashlytics | `firebase_crashlytics: ^5.0.5` |
| Remote Config | `firebase_remote_config: ^6.1.3` |
| Notifications | `flutter_local_notifications: ^19.5.0` + `timezone` + `flutter_ringtone_player` |
| Ads | `google_mobile_ads: ^7.0.0` |
| UI | `flutter_screenutil` · `flutter_svg` · `lottie` · `font_awesome_flutter` · `fl_chart` · `tutorial_coach_mark` · `pin_code_fields` |
| Localization | `intl: ^0.20.2` · `flutter_localization` · `flutter_localizations` |
| Location | `geolocator` · `geocoding` · `permission_handler` |
| Reports | `pdf` · `printing` · `excel` · `path_provider` |
| Deep Links | `app_links: ^7.0.0` |
| Misc | `share_plus` · `url_launcher` · `rate_my_app` · `upgrader` · `package_info_plus` · `flutter_contacts` · `dartz` |

---

## هيكل المشروع

```
farkha/
├── front_end/farkha_app/      ← هذا المشروع
├── front_end/farkha_admin/    ← لوحة تحكم Admin (Flutter)
└── backend_farkha/            ← PHP REST API + MySQL (MAMP)
```

### lib/

```
lib/
├── main.dart
├── core/
│   ├── class/         — CRUD, StatusRequest, HandlingData
│   ├── constant/      — routes, theme, api endpoints, ad IDs
│   ├── functions/     — validation, formatting, helpers
│   ├── middleware/    — route guards
│   ├── package/       — third-party package configs
│   ├── services/      — initialization, notifications, permissions, dark/light
│   └── shared/        — shared widgets
├── data/
│   ├── data_source/remote/   — API calls per feature
│   └── model/                — *Model classes
├── logic/
│   ├── bindings/      — *Binding (GetX DI)
│   └── controller/    — *Controller extends GetxController
└── view/
    ├── screen/        — full screens
    └── widget/        — reusable widgets
```

### Backend
كل endpoint في ملف PHP منفصل داخل `backend_farkha/app/`. الـ queries في `backend_farkha/core/queries/`.

---

## البدء

### المتطلبات
- Flutter SDK ≥ 3.7.2 (channel stable)
- Dart SDK ≥ 3.7.2
- Xcode 15+ لتطوير iOS
- Android Studio / SDK 23+
- مشروع Firebase مهيّأ مع `google-services.json` و `GoogleService-Info.plist`
- ملف `.env` في جذر المشروع

### التثبيت

```bash
cd front_end/farkha_app
flutter pub get
```

### ملف `.env`

ملف `.env` مُسجَّل كـ asset في `pubspec.yaml`. أنشئ الملف في جذر المشروع وضع فيه المتغيّرات المطلوبة (API endpoints, ad IDs, إلخ.).

---

## أوامر شائعة

```bash
# تشغيل التطبيق مع متغيّرات البيئة
flutter run --dart-define-from-file=.env

# بناء Android
flutter build apk --release
flutter build appbundle --release

# بناء iOS
flutter build ios --release

# الاختبارات
flutter test
flutter test integration_test/

# الفحص والتنسيق
flutter analyze
dart format lib/

# إعادة بناء أيقونات التطبيق
dart run flutter_launcher_icons

# تنظيف
flutter clean && flutter pub get
```

---

## Architecture (MVVM + GetX)

- **Models:** suffix `*Model` — في `data/model/`
- **Controllers:** `*Controller extends GetxController` — في `logic/controller/`
- **Bindings:** suffix `*Binding` — Dependency Injection عبر GetX
- **Services:** singleton مع suffix `*Service`
- **Views:** الشاشات الكاملة في `view/screen/`، widgets قابلة لإعادة الاستخدام في `view/widget/`

### التواصل مع الـ API
- جميع طلبات HTTP تمرّ عبر `core/class/crud.dart`
- حالات الطلب يُمثّلها `StatusRequest` enum
- معالجة الاستجابة عبر `HandlingData`

### الثيم
- التبديل بين Light/Dark عبر `DarkLightService`
- تعريف الثيم في `core/constant/theme/`
- التطبيق ملفوف بـ `ScreenUtilInit`

---

## الاختبارات

البنية التحتية للاختبارات أُضيفت في Spec 001:
- `flutter_test` (SDK)
- `mocktail: ^1.0.0` لـ mocking
- `integration_test` (SDK) للاختبارات على الجهاز
- مساعدات اختبار + DI refactor للـ controllers (52 اختبار حالياً)

```bash
flutter test                       # كل اختبارات الوحدة
flutter test test/path/to_test.dart   # اختبار محدد
```

---

## Specs الحديثة

| Spec | الوصف |
|------|-------|
| 001-testing-setup | بنية تحتية للاختبارات، 52 اختبار |
| 002-phone-verification | تحقق برقم الهاتف عبر OTP |
| 004-cycle-rating | تقييم الدورات (`cycle_feedbacks` table) |
| 005-ios-platform-parity | دعم iOS (FCM, deep links, Google Sign-In). الإعلانات معطّلة على iOS |
| 006-database-overhaul | إعادة هيكلة قاعدة البيانات + إضافة `user_devices` |

---

## المساهمة

- اتّبع الـ naming conventions الموثّقة في `AGENTS.md` و `CLAUDE.md`
- شغّل `flutter analyze` قبل الـ commit
- تأكّد من توافق RTL لأي تغيير في الواجهة
- اختبر على وضعَي Light و Dark
- أنشئ commits صغيرة وواضحة

---

## License

Private — جميع الحقوق محفوظة.
