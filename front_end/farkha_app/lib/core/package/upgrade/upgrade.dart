import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'messages.dart';

class Upgrade extends StatelessWidget {
  final Widget child;
  const Upgrade({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
        upgrader: Upgrader(
          
          durationUntilAlertAgain: Duration(),
          minAppVersion: "1.5.8",
          

          messages: UpgradeMessages(),
        ),
        
        child: child,);
  }
}
