import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdGate extends StatelessWidget {
  const AdGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) return child;
    return const SizedBox.shrink();
  }
}
