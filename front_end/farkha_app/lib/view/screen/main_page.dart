import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';
import 'body/mobile_body.dart';
import 'body/web_body.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileBody: MobileBody(),
        webBody: WebBody(),
      ),
    );
  }
}
