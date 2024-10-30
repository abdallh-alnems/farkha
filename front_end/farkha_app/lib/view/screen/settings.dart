import 'package:flutter/material.dart';

import '../widget/app_bar/app_bar_setting.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        AppBarSetting(),
      ],),
    );
  }
}