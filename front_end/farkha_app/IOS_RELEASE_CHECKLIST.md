# قائمة المهام قبل رفع نسخة iOS على App Store

> هذا الملف فيه كل اللي ناقص أو معطّل في iOS وعايز تكمّله/تفعّله قبل ما ترفع التطبيق على App Store.
> رتّب المهام حسب الأولوية: **مطلوب** → **اختياري حسب الميزة**.

---

## ١. تقييم التطبيق على App Store (rate_my_app)

📁 `lib/core/package/rating_app.dart` — السطر 13

**المشكلة الحالية:**
```dart
appStoreIdentifier: '',   // ← فاضي
```

**اللي محتاجة تعمله:**
1. خد الـ **App Store ID الرقمي** من App Store Connect (مثال: `1234567890`).
   - تلاقيه في App Store Connect → My Apps → تطبيقك → App Information → Apple ID.
2. حطه في الكود:
   ```dart
   appStoreIdentifier: '1234567890',
   ```

**النتيجة:** لما المستخدم على iPhone يضغط "تقييم" في dialog `RateMyApp`، التطبيق يفتح صفحة التطبيق على App Store.

**لو تركته فاضي:** المستخدم يضغط "تقييم" → ما يحصلش حاجة (الـ deep link يفشل بصمت).

---

## ٢. إعلانات Google Mobile Ads على iOS

### أ. تفعيل التهيئة في Dart

📁 `lib/core/services/initialization.dart` — السطر 65

**الحالي:**
```dart
if (defaultTargetPlatform == TargetPlatform.android) {
  MobileAds.instance.initialize().then((_) {
    InterstitialAdService.instance.load();
  });
}
```

**عدّلها لـ:**
```dart
MobileAds.instance.initialize().then((_) {
  InterstitialAdService.instance.load();
});
```

### ب. شيل الـ guards من ملفات الإعلانات

شيل كل `if (defaultTargetPlatform != TargetPlatform.android) return;` من:
- `lib/view/widget/ad/interstitial.dart` — السطر 21، 44
- `lib/view/widget/ad/banner.dart` — السطر 41، 54
- `lib/view/widget/ad/native.dart`
- `lib/view/widget/tools/tools_button.dart`

### ج. ضيف Ad Unit IDs لـ iOS

📁 `lib/core/constant/id/ad_id.dart`

دلوقتي فيه Ad IDs لـ Android بس. لازم تضيف Ad IDs لـ iOS من AdMob console. الأفضل تعدّل الكلاس عشان يدعم الاتنين:

```dart
import 'dart:io' show Platform;
import '../../services/test_mode_manager.dart';

class AdManager {
  // === Production IDs (Android) ===
  static const String _prodAndroidBanner = 'ca-app-pub-8595701567488603/1751748833';
  static const String _prodAndroidNative = 'ca-app-pub-8595701567488603/4494984718';
  static const String _prodAndroidInterstitial = 'ca-app-pub-8595701567488603/5421039211';

  // === Production IDs (iOS) — ضيفهم من AdMob ===
  static const String _prodIosBanner = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodIosNative = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodIosInterstitial = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // === Test IDs (Google's official test units) ===
  static const String _testAndroidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testAndroidNative = 'ca-app-pub-3940256099942544/2247696110';
  static const String _testAndroidInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testIosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testIosNative = 'ca-app-pub-3940256099942544/3986624511';
  static const String _testIosInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static String get idBanner {
    if (TestModeManager.shouldUseTestAds) {
      return Platform.isIOS ? _testIosBanner : _testAndroidBanner;
    }
    return Platform.isIOS ? _prodIosBanner : _prodAndroidBanner;
  }

  static String get idNative {
    if (TestModeManager.shouldUseTestAds) {
      return Platform.isIOS ? _testIosNative : _testAndroidNative;
    }
    return Platform.isIOS ? _prodIosNative : _prodAndroidNative;
  }

  static String get idInterstitial {
    if (TestModeManager.shouldUseTestAds) {
      return Platform.isIOS ? _testIosInterstitial : _testAndroidInterstitial;
    }
    return Platform.isIOS ? _prodIosInterstitial : _prodAndroidInterstitial;
  }
}
```

### د. حدّث `Info.plist`

📁 `ios/Runner/Info.plist`

`GADApplicationIdentifier` موجود بالفعل لكن مفروض تغيّر القيمة لـ **iOS App ID** من AdMob (مش Android). شكلها:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

### هـ. شيل `GADDelayAppMeasurementInit`

📁 `ios/Runner/Info.plist`

دلوقتي مضيف:
```xml
<key>GADDelayAppMeasurementInit</key>
<true/>
```

شيل المفتاحين دول لما تفعّل الإعلانات (لأنه بيؤجّل قياسات SDK اللي بقيت محتاجها).

---

## ٣. App Tracking Transparency (ATT)

**مطلوب على iOS 14.5+ لو هتعرض إعلانات شخصية أو هتجمع IDFA.**

### أ. ضيف الـ key في Info.plist

📁 `ios/Runner/Info.plist`

```xml
<key>NSUserTrackingUsageDescription</key>
<string>نستخدم هذا الإذن لتقديم إعلانات أكثر ملاءمة لاهتماماتك.</string>
```

### ب. أضف package في pubspec.yaml

```yaml
dependencies:
  app_tracking_transparency: ^2.0.6  # أو الأحدث
```

### ج. اطلب الإذن قبل تهيئة الإعلانات

في `lib/core/services/initialization.dart`، قبل `MobileAds.instance.initialize()`:

```dart
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

if (Platform.isIOS) {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}
```

**ملاحظة:** Apple بترفض التطبيق لو حاولت تجمع IDFA من غير ما تطلب الإذن ده.

---

## ٤. SKAdNetwork IDs (لـ Attribution على iOS)

📁 `ios/Runner/Info.plist`

علشان قياس فعّالية حملاتك الإعلانية على iOS، ضيف قائمة `SKAdNetworkItems`. Google بيوفرها جاهزة:

https://developers.google.com/admob/ios/quick-start#update_your_infoplist

انسخ الـ block الكبير من الصفحة دي (بيحتوي ~50 entry) وحطه في Info.plist.

---

## ٥. تأكيد إن Test Mode flags كلها false

📁 `lib/core/services/test_mode_manager.dart`

تأكد قبل أي build للإطلاق:

```dart
static const bool _isAppInDevelopment = false;        // ✅
static const bool _isAdsInTestMode = false;            // ⚠️ دلوقتي true
static const bool _showTutorialEveryTime = false;     // ✅
static const bool _alwaysShowReviewPrompt = false;    // ✅
static const bool _alwaysShowCycleFeedback = false;   // ✅
static const bool _alwaysShowStoreRatePrompt = false; // ✅
```

**`_isAdsInTestMode` لسه `true`** — لازم تخليها `false` قبل أي إصدار إنتاج (وإلا الإعلانات هتكون اختبار ومش هتجيب فلوس).

---

## ٦. Bundle ID و Signing على iOS

📁 `ios/Runner.xcworkspace`

افتح المشروع في Xcode وتأكد:
- Bundle Identifier متطابق مع اللي عاملاه في App Store Connect
- Signing Team مظبوط
- Provisioning Profile للـ Distribution موجود
- Version و Build Number محدّثين

---

## ٧. Privacy Manifest (PrivacyInfo.xcprivacy) — مطلوب من Apple

من مايو 2024، Apple بترفض تطبيقات بدون `PrivacyInfo.xcprivacy`. ضيف الملف في `ios/Runner/PrivacyInfo.xcprivacy` يحتوي على:
- البيانات اللي بتجمعها (Email, Name, Phone, Device ID, etc.)
- الـ tracking domains
- الـ APIs اللي ممكن تكون privacy-sensitive (User Defaults, File Timestamp, ...)

شوف: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files

Firebase و Google Mobile Ads بيوفّروا Privacy Manifests الخاصة بيهم تلقائياً، بس لازم تكون عندك واحدة لتطبيقك.

---

## ٨. اختبر على جهاز فعلي قبل الرفع

- TestFlight build → جرّب الإعلانات تظهر فعلاً
- جرّب dialog التقييم لو ضغطت "تقييم" يفتح App Store
- جرّب ATT prompt يظهر مرة واحدة عند launch
- جرّب push notifications (لو مفعّلة)
- جرّب Sign in with Google
- جرّب رفع ملف PDF / مشاركة

---

## ملخص كل البنود

| البند | الحالة دلوقتي | المطلوب قبل الإطلاق |
|------|---------------|----------------------|
| `appStoreIdentifier` في rate_my_app | فاضي | ضيف Apple ID الرقمي |
| Google Mobile Ads على iOS | معطّل | فعّل في initialization.dart + شيل guards |
| iOS Ad Unit IDs | مش موجودة | أنشئها في AdMob واحطّها في ad_id.dart |
| `GADApplicationIdentifier` | بـ ID Android | غيّره لـ iOS App ID من AdMob |
| `GADDelayAppMeasurementInit` | true (لتقليل prompt الشبكة) | شيله بعد تفعيل الإعلانات |
| App Tracking Transparency | مش موجود | ضيف key + package + كود طلب الإذن |
| SKAdNetwork Items | مش موجود | انسخ من docs Google |
| `_isAdsInTestMode` | true | خليها false |
| Privacy Manifest (xcprivacy) | مش موجود | ضيفه |
