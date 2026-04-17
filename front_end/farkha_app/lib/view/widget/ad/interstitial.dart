import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/constant/id/ad_id.dart';

/// خدمة الإعلان البيني (يملأ الشاشة كاملاً)
/// يُعرض كل [showEveryNTimes] مرة من فتح أداة
class InterstitialAdService {
  InterstitialAdService._();
  static final InterstitialAdService instance = InterstitialAdService._();

  InterstitialAd? _ad;
  bool _isAdLoaded = false;
  int _openCount = 0;

  /// عرض الإعلان كل كم مرة (الافتراضي: كل مرة)
  static const int showEveryNTimes = 1;

  /// تحميل الإعلان مسبقاً (استدعه عند بدء التطبيق أو بعد الإغلاق)
  void load() {
    InterstitialAd.load(
      adUnitId: AdManager.idInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isAdLoaded = true;
          debugPrint('✅ الإعلان البيني جاهز');
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          _ad = null;
          debugPrint('❌ فشل تحميل الإعلان البيني: ${error.message}');
          // إعادة المحاولة بعد 30 ثانية
          Future.delayed(const Duration(seconds: 30), load);
        },
      ),
    );
  }

  /// اعرض الإعلان إذا كان جاهزاً، ثم نفّذ [onComplete]
  void show({VoidCallback? onComplete}) {
    _openCount++;

    // تحقق من عدد المرات
    if (_openCount % showEveryNTimes != 0) {
      onComplete?.call();
      return;
    }

    if (!_isAdLoaded || _ad == null) {
      onComplete?.call();
      return;
    }

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        _isAdLoaded = false;
        onComplete?.call();
        // أعد تحميل الإعلان التالي
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        _isAdLoaded = false;
        onComplete?.call();
        load();
        debugPrint('❌ فشل عرض الإعلان البيني: ${error.message}');
      },
    );

    _ad!.show();
    _ad = null;
    _isAdLoaded = false;
  }
}
