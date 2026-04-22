# Farkha App

تطبيق Flutter لإدارة مزارع الدواجن. الواجهة عربية RTL.

## هيكل المشروع

```
farkha/
├── front_end/farkha_app/    — تطبيق Flutter (هذا المشروع)
├── front_end/farkha_admin/  — لوحة تحكم Admin (Flutter)
└── backend_farkha/          — PHP REST API
```

## Architecture

MVVM باستخدام GetX:

```
lib/
├── core/
│   ├── class/       — CRUD, StatusRequest, HandlingData
│   ├── constant/    — routes, theme, api, ad IDs
│   ├── services/    — initialization, notifications, permissions
│   └── shared/      — shared widgets
├── data/
│   ├── data_source/remote/  — API calls per feature
│   └── models/
├── logic/
│   ├── bindings/    — GetX dependency injection
│   └── controller/  — GetX controllers
└── view/
    ├── screen/      — full screens
    └── widget/      — reusable widgets
```

## Tech Stack

- **State:** GetX (`get: ^4.7.2`) — GetxController, GetBuilder, Obx
- **HTTP:** `core/class/crud.dart` — CRUD class wraps all API calls
- **Firebase:** Auth, Analytics, Crashlytics, Messaging, Remote Config
- **Auth:** Firebase Auth + Google Sign-In
- **UI:** flutter_screenutil, Cairo font, flutter_svg, lottie
- **Localization:** Arabic (ar) default, flutter_localizations
- **Env:** flutter_dotenv — `.env` file required

## Conventions

- Controllers: `*Controller` extends `GetxController`
- Models: `*Model` suffix
- Bindings: `*Binding` suffix
- API responses handled via `StatusRequest` enum + `HandlingData`
- Light/Dark mode via `DarkLightService`

## Commands

```bash
flutter run --dart-define-from-file=.env
flutter build apk --release
flutter build appbundle --release
flutter test
flutter analyze
flutter clean && flutter pub get
```

## Backend PHP

كل endpoint في ملف منفصل داخل `backend_farkha/app/`. الـ queries في `backend_farkha/core/queries/`.

## Active Technologies
- Dart 3.7.2+ / Flutter SDK stable
- `flutter_test` (SDK)
- `mocktail ^1.0.x` (dev dep)
- `integration_test` (SDK, dev dep)
- Dart 3.7.2+ / Flutter SDK (channel stable) · PHP 8.x على MAMP · MySQL 5.7+/MariaDB (المزوَّد مع MAMP) + GetX 4.7.2 · `get_storage: ^2.1.1` (موجود مسبقاً في `pubspec.yaml`) · Firebase (Core/Auth/Analytics/Crashlytics/Remote Config) · `http` عبر `core/class/crud.dart` · `flutter_screenutil` · `flutter_dotenv` · `package_info_plus` (لقراءة `app_version`) · `dart:io Platform` (لـ `platform`) (003-app-reviews)
- MySQL جدول جديد `app_reviews` في نفس قاعدة البيانات المحلية على MAMP · `get_storage` للقيم المحلية الخاصة بالنافذة التلقائية · لا Firebase Firestore ولا Realtime DB في هذه الميزة (003-app-reviews)

## Recent Changes
- 001-testing-setup: Added test infrastructure — mocktail, test helpers, controller DI refactor, 52 tests
