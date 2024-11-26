import 'package:flutter/material.dart';
import '../../widget/ad/banner/ad_second_banner.dart';
import '../../widget/app_bar/custom_app_bar.dart';

class BroilerChickenRequirements extends StatelessWidget {
  const BroilerChickenRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController countController = TextEditingController();

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "احتياجات فراخ التسمين",
          ),
         
        ],
      ),
      bottomNavigationBar: const AdSecondBanner(),
    );
  }
}
