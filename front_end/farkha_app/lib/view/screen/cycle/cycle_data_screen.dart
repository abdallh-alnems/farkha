import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../logic/controller/cycle_controller.dart';
import '../../../logic/controller/cycle_custom_data_controller.dart';
import '../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/cycle_sub_screen_appbar.dart';
import '../../widget/cycle/data_cards/average_weight_card.dart';
import '../../widget/cycle/data_cards/custom_data_card.dart';
import '../../widget/cycle/data_cards/custom_data_dialogs.dart';
import '../../widget/cycle/data_cards/feed_consumption_card.dart';
import '../../widget/cycle/data_cards/medication_card.dart';
import '../../widget/cycle/data_cards/mortality_card.dart';

class CycleDataScreen extends StatefulWidget {
  const CycleDataScreen({super.key});

  @override
  State<CycleDataScreen> createState() => _CycleDataScreenState();
}

class _CycleDataScreenState extends State<CycleDataScreen>
    with TickerProviderStateMixin {
  late final CycleController cycleCtrl;
  late final CycleCustomDataController customDataCtrl;
  late final BroilerController broilerCtrl;
  late final AnimationController _fadeController;

  bool get _isViewer => cycleCtrl.currentCycle['role']?.toString() == 'viewer';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (!Get.isRegistered<CycleController>()) {
      Get.put(CycleController());
    }
    if (!Get.isRegistered<BroilerController>()) {
      Get.put(BroilerController());
    }
    Get.put(CycleCustomDataController(), permanent: true);
    cycleCtrl = Get.find<CycleController>();
    customDataCtrl = Get.find<CycleCustomDataController>();
    broilerCtrl = Get.find<BroilerController>();

    final cycleId = cycleCtrl.currentCycle['cycle_id'];
    if (cycleId != null) {
      final cycleIdInt =
          cycleId is int ? cycleId : int.tryParse(cycleId.toString());
      if (cycleIdInt != null && cycleIdInt > 0) {
        cycleCtrl.fetchCycleDetails(cycleIdInt, silent: true);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CycleSubScreenAppBar(
        titlePrefix: 'إدخال بيانات',
        onAddPressed: _isViewer ? null : showAddDataDialog,
      ),
      body: Obx(() {
        if (cycleCtrl.cycleDetailsStatus.value == StatusRequest.loading) {
          return SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 36.w,
                    height: 36.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5.w,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'جاري تحميل البيانات...',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: RefreshIndicator(
            color: colorScheme.primary,
            onRefresh: () => cycleCtrl.forceRefreshCurrentCycle(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 90.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _staggerChild(0, const MortalityCard()),
                  _staggerChild(1, const AverageWeightCard()),
                  _staggerChild(
                    2,
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: const AdNativeWidget(),
                    ),
                  ),
                  _staggerChild(3, const MedicationCard()),
                  _staggerChild(4, const FeedConsumptionCard()),
                  Obx(() {
                    final items = customDataCtrl.customDataItems;
                    if (items.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: items.asMap().entries.map((e) {
                        return _staggerChild(
                          5 + e.key,
                          CustomDataCard(
                            item: e.value,
                            itemIndex: e.key,
                            isViewer: _isViewer,
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _staggerChild(int index, Widget child) {
    const step = 0.07;
    final begin = (index * step).clamp(0.0, 0.65);
    final end = (begin + 0.35).clamp(0.0, 1.0);

    final opacity = _fadeController.drive(
      CurveTween(curve: Interval(begin, end, curve: Curves.easeOut)),
    );
    final offset = _fadeController.drive(
      Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).chain(CurveTween(curve: Interval(begin, end, curve: Curves.easeOut))),
    );

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: offset,
        child: Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: child,
        ),
      ),
    );
  }
}
