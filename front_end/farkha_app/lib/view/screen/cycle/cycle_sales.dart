import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_sales_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/appbar/cycle_sub_screen_appbar.dart';
import '../../widget/cycle/sales/sale_card.dart';
import '../../widget/cycle/sales/sales_dialogs.dart';
import '../../widget/cycle/sales/sales_hero.dart';

class CycleSalesScreen extends StatefulWidget {
  const CycleSalesScreen({super.key});

  @override
  State<CycleSalesScreen> createState() => _CycleSalesScreenState();
}

class _CycleSalesScreenState extends State<CycleSalesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heroController;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heroController.forward();

    if (!Get.isRegistered<CycleController>()) {
      Get.put(CycleController());
    }
    if (!Get.isRegistered<CycleSalesController>()) {
      Get.put(CycleSalesController());
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salesCtrl = Get.find<CycleSalesController>();
    final cycleCtrl = Get.find<CycleController>();

    return Scaffold(
      appBar: CycleSubScreenAppBar(
        titlePrefix: 'مبيعات',
        onAddPressed: () => showAddSaleDialog(context, salesCtrl),
      ),
      body: Obx(() {
        if (salesCtrl.statusRequest.value == StatusRequest.loading) {
          return const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => salesCtrl.fetchSales(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SalesHero(
                    controller: salesCtrl,
                    heroController: _heroController,
                  ),
                  SizedBox(height: 24.h),
                  SalesSection(
                    controller: salesCtrl,
                    isViewer: cycleCtrl.currentCycle['role']?.toString() == 'viewer',
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
