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
  final List<int> _retryDelays = [5, 10, 20, 30, 40, 50, 60];

  @override
  void initState() {
    super.initState();
    // تحميل إعلان جديد بعد انتهاء build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNewAd();
    });
  }

  @override
  void dispose() {
    _disposeCurrentAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded && _nativeAd != null
        ? SizedBox(
          width: double.infinity,
          height: 280,
          child: AdWidget(ad: _nativeAd!),
        )
        : const SizedBox();
  }

  void _loadNewAd() {
    // تحميل إعلان جديد في كل مرة
    _disposeCurrentAd();

    _nativeAd = NativeAd(
      adUnitId: AdManager.idNative,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _retryCount = 0; // إعادة تعيين عداد المحاولات عند النجاح
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _retryWithBackoff();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
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

  void _retryWithBackoff() {
    if (!mounted) return;

    // تحديد فترة الانتظار بناءً على عدد المحاولات
    int delayIndex =
        _retryCount < _retryDelays.length
            ? _retryCount
            : _retryDelays.length - 1;
    int delaySeconds = _retryDelays[delayIndex];

    _retryCount++;

    Future.delayed(Duration(seconds: delaySeconds), () {
      if (mounted) {
        _loadNewAd();
      }
    });
  }

  void _disposeCurrentAd() {
    if (_nativeAd != null) {
      _nativeAd?.dispose();
      _nativeAd = null;
      _isAdLoaded = false;
      _retryCount = 0; // إعادة تعيين عداد المحاولات
    }
  }
}
