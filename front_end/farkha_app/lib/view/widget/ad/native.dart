import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/constant/id/ad_id.dart';

class AdNativeWidget extends StatefulWidget {
  const AdNativeWidget({super.key});

  @override
  State<AdNativeWidget> createState() => _AdNativeWidgetState();
}

class _AdNativeWidgetState extends State<AdNativeWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // لا تعرض شيء إذا الإعلان لم يُحمّل
    if (!_isAdLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    // Responsive height based on screen width (for medium template)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double adHeight = (screenWidth * 0.75).clamp(280.0, 350.0);

    return SizedBox(
      width: double.infinity,
      height: adHeight,
      child: AdWidget(ad: _nativeAd!),
    );
  }

  void _loadAd() {
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _nativeAd = NativeAd(
      adUnitId: AdManager.idNative,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _retryCount = 0;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native failed: ${error.code} - ${error.message}');
          ad.dispose();
          _nativeAd = null;
          _scheduleRetry();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: isDark ? Colors.grey[900]! : Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: isDark ? Colors.white : Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    )..load();
  }

  void _scheduleRetry() {
    if (!mounted || _isAdLoaded || _retryCount >= _maxRetries) return;

    _retryCount++;
    final int delaySeconds = _retryCount * 20;

    Future.delayed(Duration(seconds: delaySeconds), () {
      if (mounted && !_isAdLoaded) {
        _loadAd();
      }
    });
  }
}
