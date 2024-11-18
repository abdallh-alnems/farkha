import 'package:farkha_app/view/widget/ad/banner/ad_second_banner.dart';
import 'package:flutter/material.dart';

import '../../widget/app_bar/custom_app_bar.dart';

class FeasibilityStudy extends StatelessWidget {
  const FeasibilityStudy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          CustomAppBar(
            text: "دراسة جدول",
          ),
        ],
      ),
      bottomNavigationBar: AdSecondBanner(),
    );
  }
}
