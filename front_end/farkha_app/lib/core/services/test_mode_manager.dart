import 'package:flutter/foundation.dart';

class TestModeManager {
  static const bool _isAppInDevelopment = false;

  /// متغير للتحكم في إظهار/إخفاء الإعلانات **أثناء التطوير فقط**.
  /// `true` = الإعلانات تظهر، `false` = الإعلانات مخفية.
  /// في النسخة النهائية (release) الإعلانات تظهر دائماً ويُتجاهَل هذا المتغير،
  /// حتى لو نسيته على `false`. لا علاقة له بكون الإعلان حقيقياً أو تجريبياً.
  static const bool _adsEnabled = false;

  static const bool _alwaysShowReviewPrompt = false;

  static const bool _alwaysShowCycleFeedback = false;

  static const bool _alwaysShowStoreRatePrompt = false;

  /// هل تظهر الإعلانات؟
  /// في النسخة النهائية (release/profile) تظهر دائماً مهما كانت قيمة [_adsEnabled].
  /// أثناء التطوير (debug) فقط يتحكم بها [_adsEnabled].
  static bool get shouldShowAds => !kDebugMode || _adsEnabled;

  /// متروك للتوافق مع الكود القديم — عكس [shouldShowAds].
  static bool get shouldDisableAds => !_adsEnabled;

  /// الإعلانات تكون تجريبية تلقائياً أثناء التطوير (debug) فقط،
  /// وتصبح حقيقية دائماً في النسخة النهائية (release/profile).
  /// لا يوجد متغير يدوي حتى لا تُشحن النسخة النهائية بإعلانات تجريبية بالخطأ.
  static bool get shouldUseTestAds => kDebugMode;

  static bool get shouldAlwaysShowReviewPrompt =>
      _isAppInDevelopment || _alwaysShowReviewPrompt;

  static bool get shouldAlwaysShowCycleFeedback =>
      _isAppInDevelopment || _alwaysShowCycleFeedback;

  static bool get shouldAlwaysShowStoreRatePrompt =>
      _isAppInDevelopment || _alwaysShowStoreRatePrompt;
}
