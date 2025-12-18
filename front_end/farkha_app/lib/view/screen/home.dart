import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/package/alert_exit_app.dart';
import '../../core/package/upgrade.dart';
import '../../core/services/initialization.dart';
import '../../core/services/test_mode_manager.dart';
import '../widget/ad/banner.dart';
import '../widget/ad/native.dart';
import '../widget/appbar/appbar_home.dart';
import '../widget/cycle/card_cycle.dart';
import '../widget/drawer/drawer.dart';
import '../widget/home/price_card.dart';
import '../widget/home/tools_section.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorialIfNeeded();
    });
  }

  void _showTutorialIfNeeded() {
    final hasSeenTutorial =
        myServices.getStorage.read<bool>('home_tutorial_seen') ?? false;

    final shouldShowTutorial =
        !hasSeenTutorial || TestModeManager.shouldShowTutorialEveryTime;

    if (shouldShowTutorial) {
      setState(() {
        _isTutorialActive = true;
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarHome(),
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
            CardCycle(),

            if (!_isTutorialActive) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 9),
                child: AdNativeWidget(),
              ),
              const SizedBox(height: 9),
            ] else
              const SizedBox(height: 77),

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
