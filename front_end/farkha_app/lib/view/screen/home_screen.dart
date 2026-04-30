import 'package:farkha_app/view/widget/home/card_cycle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/routes/route.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/package/alert_exit_app.dart';
import '../../core/package/upgrade.dart';
import '../../core/services/initialization.dart';
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

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
      final permissionController = Get.find<PermissionController>();
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
          children: [
            const TapToExit(child: Column(children: [Upgrade()])),

            PriceCard(
              priceCardKey: HomeTutorial.priceCardKey,
              allPricesButtonKey: HomeTutorial.allPricesButtonKey,
              settingsIconKey: HomeTutorial.settingsIconKey,
            ),

            const InvitationCard(),

            const CardCycle(),
            if (!_isTutorialActive) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 17),
                child: AdNativeWidget(),
              ),
              const SizedBox(height: 7),
            ] else
              const SizedBox(height: 0),

            ToolsSection(
              toolsSectionKey: HomeTutorial.toolsSectionKey,
              toolsTitleKey: HomeTutorial.toolsTitleKey,
              viewAllKey: HomeTutorial.viewAllKey,
              toolsScrollViewKey: HomeTutorial.toolsScrollViewKey,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isTutorialActive ? null : const AdBannerWidget(),
    );
  }
}
