# Farkha App - تطبيق إدارة مزارع الدواجن

Flutter mobile application for comprehensive poultry farm management (إدارة مزارع الدواجن).

## Overview
Farkha is a full-featured poultry farm management application that helps farmers track their farm cycles, monitor bird health, manage feed and vaccinations, track market prices, and access farming tools and utilities.

## Features

### Core Features
- **User Authentication**: Firebase Auth + Google Sign-In
- **Farm Cycle Management**: Track weight, feed consumption, mortality, and expenses
- **Market Prices**: Real-time poultry market price tracking
- **Farm Tools**: Utilities and calculators for farm management
- **Weather Integration**: Local weather data for farm planning
- **Disease & Vaccination Tracking**: Monitor health and vaccination schedules

### Data Management
- **PDF/Excel Export**: Generate reports for cycle data
- **Feasibility Studies**: Calculate farm profitability
- **Custom Notes**: Add custom data points to cycles
- **Sales & Expenses Tracking**: Monitor financial data

### User Experience
- **Arabic RTL Interface**: Full Arabic language support
- **Dark/Light Mode**: Theme switching support
- **Responsive Design**: Adapts to all screen sizes using flutter_screenutil
- **Onboarding**: Guided first-time user experience
- **Push Notifications**: Real-time alerts and updates
- **Deep Linking**: Navigate to specific app sections via links
- **Remote Config**: Dynamic feature control

### Monetization
- **Google Mobile Ads**: Banner and interstitial ads
- **Meta Mediation**: Additional ad network support

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.7.2+ |
| State Management | GetX |
| Backend | Firebase + PHP API |
| Analytics | Firebase Analytics |
| Crash Reporting | Firebase Crashlytics |
| Auth | Firebase Auth + Google Sign-In |
| Notifications | Firebase Messaging |
| Ads | Google Mobile Ads + Meta |
| localization | Arabic (ar) with flutter_localizations |
| Responsive UI | flutter_screenutil |
| Font | Cairo |

## Project Structure

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

## Getting Started

### Prerequisites
- Flutter SDK >= 3.7.2
- Dart SDK >= 3.7.2
- Firebase project configured
- `.env` file with API endpoints

### Installation

```bash
# Clone the repository
git clone <repository-url>

# Navigate to the project
cd farkha_app

# Install dependencies
flutter pub get

# Create .env file with required variables
# See .env.example for reference

# Run the app
flutter run
```

### Useful Commands

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

## Environment Setup

Create a `.env` file in the project root with the following variables:

```env
API_BASE_URL=your_api_base_url
FIREBASE_PROJECT_ID=your_project_id
# Add other required variables
```

## Architecture

The app follows MVVM (Model-View-ViewModel) pattern using GetX:

- **Models**: Data classes with `*Model` suffix
- **Controllers**: GetX controllers with `*Controller` suffix extending `GetxController`
- **Bindings**: Dependency injection with `*Binding` suffix
- **Services**: Singleton services with `*Service` suffix
- **Views**: Screens in `view/screen/`, reusable widgets in `view/widget/`

### API Communication
- Custom `CRUD` class in `core/class/crud.dart`
- `StatusRequest` enum for request states
- `HandlingData` for response processing

### Theme
- Light/Dark mode via `DarkLightService`
- Theme definitions in `core/constant/theme/theme.dart`
- `ScreenUtilInit` wraps the entire app

## Planned Features

### High Priority
- [ ] Graphical reports: Charts for weight, feed consumption, and mortality trends
- [ ] Cycle comparison: Compare different farm cycles
- [ ] PDF export: Printable and shareable reports

### Medium Priority
- [ ] Cloud backup: Save data to cloud storage
- [ ] Alerts: Notifications for high mortality or weight drops
- [ ] Smart tips: Data-driven farming advice

### Advanced (Optional)
- [ ] AI predictions: Advanced analytics and forecasting
- [ ] IoT integration: Sensor device connectivity
- [ ] Multi-farm management: Support for multiple farms

## Contributing

1. Follow the naming conventions documented in AGENTS.md
2. Run `flutter analyze` before submitting changes
3. Ensure Arabic RTL compatibility for all UI changes
4. Test on both light and dark themes

## License

Private - All rights reserved
