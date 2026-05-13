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
import '../../logic/controller/review_prompt_controller.dart';
import '../widget/ad/banner.dart';
import '../widget/ad/native.dart';
import '../widget/appbar/appbar_home.dart';
import '../widget/drawer/drawer.dart';

import '../widget/home/price_card.dart';
import '../widget/home/tools_section.dart';
import '../widget/home/invitation_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with WidgetsBindingObserver {
  MyServices myServices = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPendingForceLogout();

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingForceLogout();
    }
  }

  void _checkPendingForceLogout() {
    NotificationService.consumePendingForceLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarHome(),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TapToExit(child: SizedBox.shrink()),

            const PriceCard(),
            SizedBox(height: 8.h),
            const InvitationCard(),
            const CardCycle(),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.w),
              child: const AdNativeWidget(),
            ),
            SizedBox(height: 7.h),
            const ToolsSection(),
            SizedBox(height: 60.h),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
