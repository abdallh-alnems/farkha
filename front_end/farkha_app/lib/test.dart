import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/constant/routes/route.dart';
import 'view/widget/ad/banner/ad_all_banner.dart';
import 'view/widget/ad/native/ad_home_native.dart';
import 'view/widget/ad/banner/ad_home_banner.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Test"),
      ),
              bottomNavigationBar: const AdAllBanner(),
    );
  }
}

class ADAD extends StatelessWidget {
  const ADAD({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("adadadad"),
      ),
         //     bottomNavigationBar: const AdmobHome(),
    );
  }
}
