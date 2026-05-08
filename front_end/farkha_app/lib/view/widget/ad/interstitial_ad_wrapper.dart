import 'package:flutter/material.dart';

import 'interstitial.dart';

class InterstitialAdWrapper extends StatefulWidget {
  final Widget child;

  const InterstitialAdWrapper({super.key, required this.child});

  @override
  State<InterstitialAdWrapper> createState() => _InterstitialAdWrapperState();
}

class _InterstitialAdWrapperState extends State<InterstitialAdWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InterstitialAdService.instance.show();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
