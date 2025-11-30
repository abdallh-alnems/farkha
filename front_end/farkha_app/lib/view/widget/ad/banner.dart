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
  AnchoredAdaptiveBannerAdSize? _adaptiveSize;

  @override
  void initState() {
    super.initState();

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
          height: (_adaptiveSize?.height ?? _bannerAd!.size.height).toDouble(),
          width: double.infinity,
          child: AdWidget(ad: _bannerAd!),
        )
        : const SizedBox();
  }

  Future<void> _loadNewAd() async {
    _disposeCurrentAd();

    // Compute anchored adaptive size based on the current width in dp
    final int adWidth = MediaQuery.of(context).size.width.truncate();
    try {
      _adaptiveSize =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            adWidth,
          );
    } catch (_) {
      _adaptiveSize = null;
    }

    final AdSize sizeToUse = _adaptiveSize ?? AdSize.banner;

    _bannerAd = BannerAd(
      size: sizeToUse,
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
          _retryWithBackoff();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  void _retryWithBackoff() {
    if (!mounted) return;
    if (_isAdLoaded) return;

    int delayIndex =
        _retryCount < _retryDelays.length
            ? _retryCount
            : _retryDelays.length - 1;
    int delaySeconds = _retryDelays[delayIndex];

    _retryCount++;

    Future.delayed(Duration(seconds: delaySeconds), () {
      if (mounted) {
        if (_isAdLoaded) return;
        _loadNewAd();
      }
    });
  }

  void _disposeCurrentAd() {
    if (_bannerAd != null) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isAdLoaded = false;
      _retryCount = 0;
    }
  }
}
