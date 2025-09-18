import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../logic/controller/price_controller/prices_stream/prices_stream_controller.dart';
import 'price_content/price_content.dart';
import 'price_header.dart';

class PriceCard extends StatelessWidget {
  const PriceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: SizedBox(
        width: double.infinity,
        child: GetBuilder<PricesStreamController>(
          builder:
              (controller) => Column(
                children: [
                  const PriceHeader(),
                  SizedBox(height: 9.h),
                  PriceContent(controller: controller),
                ],
              ),
        ),
      ),
    );
  }
}
