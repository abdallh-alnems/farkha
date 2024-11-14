import 'package:flutter/material.dart';

import '../../widget/app_bar/custom_app_bar.dart';

class FeedConsumption extends StatelessWidget {
  const FeedConsumption({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "استهلاك العلف",
          ),
        ],
      ),
    );
  }
}