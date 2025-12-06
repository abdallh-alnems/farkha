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
  static const int _maxRetries = 3;

  // Adaptive banner height (will be set after loading)
  double _adHeight = 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdaptiveAd();
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // لا تعرض شيء إذا الإعلان لم يُحمّل
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _adHeight,
      width: double.infinity,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Future<void> _loadAdaptiveAd() async {
    if (!mounted) return;

    // Get adaptive banner size based on screen width
    final int adWidth = MediaQuery.of(context).size.width.truncate();
    final AnchoredAdaptiveBannerAdSize? adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(adWidth);

    // Fallback to standard banner if adaptive size fails
    final AdSize adSize = adaptiveSize ?? AdSize.banner;

    // Update height for adaptive size
    if (mounted) {
      setState(() {
        _adHeight = (adaptiveSize?.height ?? 60).toDouble();
      });
    }

    _bannerAd = BannerAd(
      size: adSize,
      adUnitId: AdManager.idBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _retryCount = 0;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: ${error.code} - ${error.message}');
          ad.dispose();
          _bannerAd = null;
          _scheduleRetry();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  void _scheduleRetry() {
    if (!mounted || _isAdLoaded || _retryCount >= _maxRetries) return;

    _retryCount++;
    final int delaySeconds = _retryCount * 15;

    Future.delayed(Duration(seconds: delaySeconds), () {
      if (mounted && !_isAdLoaded) {
        _loadAdaptiveAd();
      }
    });
  }
}
