import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../logic/controller/price_controller/prices_card/prices_card_controller.dart';
import '../prices/prices_card/price_content/price_content.dart';
import '../prices/prices_card/price_header.dart';

class PriceCard extends StatefulWidget {
  final GlobalKey? priceCardKey;
  final GlobalKey? allPricesButtonKey;
  final GlobalKey? settingsIconKey;

  const PriceCard({
    super.key,
    this.priceCardKey,
    this.allPricesButtonKey,
    this.settingsIconKey,
  });

  @override
  State<PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<PriceCard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Get.find<PricesCardController>().refreshData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: SizedBox(
        width: double.infinity,
        child: GetBuilder<PricesCardController>(
          builder:
              (controller) => Column(
                key: widget.priceCardKey,
                children: [
                  PriceHeader(
                    allPricesButtonKey: widget.allPricesButtonKey,
                    settingsIconKey: widget.settingsIconKey,
                  ),
                  SizedBox(height: 9.h),
                  PriceContent(controller: controller),
                ],
              ),
        ),
      ),
    );
  }
}
