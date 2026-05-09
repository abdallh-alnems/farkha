import 'package:farkha_app/view/widget/home/cycle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constant/routes/route.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/package/alert_exit_app.dart';
import '../../core/services/initialization.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/permission.dart';
import '../../core/services/test_mode_manager.dart';
import '../../logic/controller/review_prompt_controller.dart';
import '../widget/ad/banner.dart';
import '../widget/ad/native.dart';
import '../widget/appbar/appbar_home.dart';
import '../widget/drawer/drawer.dart';

import '../widget/home/price_card.dart';
import '../widget/home/tools_section.dart';
import '../widget/home/invitation_card.dart';
import '../widget/tutorial/home_tutorial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  bool _isTutorialActive = false;
  MyServices myServices = Get.find();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pending = myServices.getStorage.read<Map<dynamic, dynamic>>(
        StorageKeys.pendingDarknessAlarm,
      );
      if (pending != null && mounted) {
        await myServices.getStorage.remove(StorageKeys.pendingDarknessAlarm);
        final args = Map<String, dynamic>.from(
          pending.map((k, v) => MapEntry(k.toString(), v)),
        );
        args['fromBackground'] = true;
        await Get.toNamed<void>(AppRoute.darknessAlarm, arguments: args);
        return;
      }
      final messagingConfigured =
          myServices.getStorage.read<bool>(StorageKeys.messagingConfigured) ?? false;
      if (!messagingConfigured) {
        await NotificationService.instance.configureMessaging();
        await myServices.getStorage.write(StorageKeys.messagingConfigured, true);
      }
      final permissionController = Get.find<PermissionController>();
      if (!mounted) return;
      await permissionController.showPermissionsIntroIfNeeded(context);
      if (!mounted) return;
      _showTutorialIfNeeded();
      _maybeShowReviewPrompt();
    });
  }

  void _maybeShowReviewPrompt() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        try {
          final promptController = Get.find<ReviewPromptController>();
          promptController.maybeShowPrompt(context);
        } catch (_) {}
      }
    });
  }

  void _showTutorialIfNeeded() {
    final hasSeenTutorial =
        myServices.getStorage.read<bool>(StorageKeys.homeTutorialSeen) ?? false;

    final shouldShowTutorial =
        !hasSeenTutorial || TestModeManager.shouldShowTutorialEveryTime;

    if (shouldShowTutorial) {
      setState(() {
        _isTutorialActive = true;
      });

      if (mounted) {
        HomeTutorial.showTutorial(
          context,
          onTutorialComplete: () {
            if (mounted) {
              setState(() {
                _isTutorialActive = false;
              });
            }
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHome(drawerKey: HomeTutorial.drawerKey),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TapToExit(child: SizedBox.shrink()),

            PriceCard(
              priceCardKey: HomeTutorial.priceCardKey,
              allPricesButtonKey: HomeTutorial.allPricesButtonKey,
              settingsIconKey: HomeTutorial.settingsIconKey,
            ),
            SizedBox(height: 8.h),
            const InvitationCard(),
            const CardCycle(),
            SizedBox(height: 14.h),
            if (!_isTutorialActive) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.w),
                child: const AdNativeWidget(),
              ),
              SizedBox(height: 7.h),
            ],
            ToolsSection(
              toolsSectionKey: HomeTutorial.toolsSectionKey,
              toolsTitleKey: HomeTutorial.toolsTitleKey,
              viewAllKey: HomeTutorial.viewAllKey,
              toolsScrollViewKey: HomeTutorial.toolsScrollViewKey,
            ),
            SizedBox(height: 60.h),
          ],
        ),
      ),
      bottomNavigationBar: _isTutorialActive ? null : const AdBannerWidget(),
    );
  }
}
