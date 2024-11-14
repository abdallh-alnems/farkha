import 'package:flutter/material.dart';

import '../../widget/app_bar/custom_app_bar.dart';

class TableAnalysis extends StatelessWidget {
  const TableAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            text: "دراسة جدول",
          ),
        ],
      ),
    );
  }
}
