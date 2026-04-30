# Farkha App - Agent Guidelines

## Project Overview
Flutter mobile application for poultry farm management (إدارة مزارع الدواجن).
- **Version**: 6.1.8+37
- **SDK**: Flutter 3.7.2+
- **State Management**: GetX
- **Backend**: Firebase + Custom PHP API

## Architecture Pattern
MVVM (Model-View-ViewModel) using GetX

```
lib/
├── core/           # Shared utilities
│   ├── class/      # Base classes (CRUD, StatusRequest, HandlingData)
│   ├── constant/   # Constants (routes, theme, Firebase, headers)
│   ├── functions/  # Helper functions (validation, formatting)
│   ├── middleware/ # Route guards
│   ├── package/    # Third-party package configs
│   ├── services/   # Singleton services (analytics, notifications, etc.)
│   └── shared/     # Shared widgets/components
├── data/           # Data layer
│   ├── data_source/ # API/Local data sources
│   └── model/       # Data models
├── logic/          # Business logic
│   ├── bindings/   # GetX dependency injection
│   └── controller/ # GetX controllers
└── view/           # UI layer
    ├── screen/     # Full screens/pages
    └── widget/     # Reusable widgets
```

## Key Technologies
- **State Management**: GetX (`get: ^4.7.2`)
- **Navigation**: GetX routing with `getPages`
- **Firebase**: Core, Auth, Analytics, Crashlytics, Messaging, App Check, Remote Config
- **Ads**: Google Mobile Ads + Meta mediation
- **Localization**: Arabic (ar) default with `flutter_localizations`
- **Responsive UI**: `flutter_screenutil`
- **Design System**: Cairo font, custom themes in `core/constant/theme/`

## Important Conventions

### Naming
- Controllers: `*Controller` (e.g., `CycleController`)
- Screens: lowercase file names in folders (e.g., `screen/home.dart`)
- Models: `*Model` suffix
- Services: `*Service` suffix
- Bindings: `*Binding` suffix

### GetX Patterns
- Use `GetBuilder` for state that rebuilds widgets
- Use `Obx` with Rx observables for reactive state
- Bind dependencies in `AppBindings` or per-route bindings
- Controllers extend `GetxController`

### API Communication
- Custom `CRUD` class in `core/class/crud.dart`
- `StatusRequest` enum for request states
- `HandlingData` for response processing

### Theme
- Light/Dark mode via `DarkLightService`
- Theme definitions in `core/constant/theme/theme.dart`
- `ScreenUtilInit` wraps the entire app

## Commands

```bash
# Run app
flutter run

# Run with environment
flutter run --dart-define-from-file=.env

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Clean build
flutter clean && flutter pub get
```

## Firebase
- Config: `lib/core/constant/firebase_options.dart`
- Services initialized in `core/services/initialization.dart`
- Analytics tracked via `AnalyticsService`

## Environment
- `.env` file required for API endpoints and keys
- Loaded via `flutter_dotenv`
- Access through `core/services/env.dart`

## Testing
- Test structure mirrors `lib/` structure under `test/`
- Shared helpers: `test/helpers/` (FakeCrud, FakeCycleData, FakeLoginData, MockFirebaseAuth, TestHarness, fixtures)
- Unit tests: `test/logic/controller/` and `test/data/`
- Widget tests: `test/view/screen/` and `test/view/widget/`
- Integration wiring: `test/integration/`
- On-device integration: `integration_test/` (requires physical device)
- Controllers accept optional constructor params for DI in tests
- See `test/README.md` for full guide

## Features
- User authentication (Firebase Auth + Google Sign-In)
- Farm cycle management (tracking weight, feed, mortality)
- Market prices tracking
- Farm tools and utilities
- Weather integration
- Disease and vaccination tracking
- Feasibility studies
- PDF/Excel export
- Push notifications
- Ad monetization
- Deep linking
- Remote config

## Notes
- Arabic RTL interface is the primary language
- Test files (`test.dart`, `test2.dart`) in lib/ are temporary dev files
- Backend PHP API exists in separate worktree

## UI/UX Design Guidelines

When building Flutter widgets or screens, apply intentional design thinking:

### Design Direction
Before coding, commit to a clear aesthetic: refined minimal, warm organic, bold editorial, luxury, etc. Every screen should feel purposefully designed, not generic.

### Flutter Design Principles
- **Typography**: Use Cairo font (already configured). Apply scale contrast — large bold headers vs. light body text.
- **Color**: Use the app's theme system (`DarkLightService`). Dominant colors + sharp accent. Avoid flat evenly-distributed palettes.
- **Spacing**: Generous and consistent via `flutter_screenutil` (`.w`, `.h`, `.sp`). Unexpected whitespace creates premium feel.
- **Motion**: Add subtle animations (`AnimationController`, `AnimatedContainer`, Hero transitions) for high-impact moments — not scattered everywhere.
- **Depth**: Use `BoxShadow`, `BorderRadius`, `Gradient` to create layers. Avoid flat cards with no depth.
- **RTL**: All layouts must respect Arabic RTL. Use `EdgeInsetsDirectional`, `MainAxisAlignment.end` where needed.

### What to Avoid
- Generic AI-looking UI: symmetric cards, purple gradients, Inter font
- Cookie-cutter `ListTile` and default `AppBar` without customization
- Placeholder icons instead of meaningful visual language

## Active Technologies
- Dart 3.7.2+ / Flutter SDK stable
- `flutter_test` (SDK) · `mocktail ^1.0.x` (dev dep) · `integration_test` (SDK, dev dep)
- **iOS 15.0+** supported (iPhone only) — AdMob disabled on iOS via `Platform.isAndroid` guards
- Bundle ID: `ni.nims.frkha` (unified across Android/iOS)

## Recent Changes
- 005-ios-platform-parity: iOS support — Bundle ID unified, Firebase iOS app, Push Notifications with Time-Sensitive darkness alarms, Universal Links + custom scheme `farkha://`, privacy manifest, AdMob disabled on iOS, Arabic usage descriptions, notification sound `.caf`, TimeSensitiveHintSheet
- 003-app-reviews: Added in-app review feature — AppReviewScreen (drawer entry), ReviewPromptController (auto-prompt after 30d + 10 unique days), offline retry, PHP backend endpoints, 29 tests
- 001-testing-setup: Added test infrastructure — mocktail, integration_test SDK, test helpers, controller DI refactor, 52 tests (unit + widget + integration)
