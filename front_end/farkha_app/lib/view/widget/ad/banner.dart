import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/constant/id/ad_id.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
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
    return _isAdLoaded && _bannerAd != null
        ? SizedBox(
          height: _bannerAd!.size.height.toDouble(),
          width: double.infinity,
          child: AdWidget(ad: _bannerAd!),
        )
        : const SizedBox();
  }

  void _loadNewAd() {
    // تحميل إعلان جديد في كل مرة
    _disposeCurrentAd();

    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdManager.idBanner,
      listener: BannerAdListener(
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
    if (_bannerAd != null) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isAdLoaded = false;
      _retryCount = 0; // إعادة تعيين عداد المحاولات
    }
  }
}
