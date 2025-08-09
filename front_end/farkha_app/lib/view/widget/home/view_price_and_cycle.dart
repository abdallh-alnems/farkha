import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cycle/card_cycle.dart';
import '../prices/card_price.dart';

class ViewPricesAndCycle extends StatelessWidget {
  const ViewPricesAndCycle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15).r,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CardCycle(),
          CardPrice(),
        ],
      ),
    );
  }
}
