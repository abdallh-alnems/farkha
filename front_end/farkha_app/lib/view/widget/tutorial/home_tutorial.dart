import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../core/constant/storage_keys.dart';
import '../../../../core/services/initialization.dart';
import '../../../../core/services/permission.dart';
import '../../../../core/services/test_mode_manager.dart';
import 'widgets/tutorial_action_buttons.dart';
import 'widgets/tutorial_content_card.dart';
import 'widgets/tutorial_target_factory.dart';

class HomeTutorial {
  // Drawer Key (menu icon in app bar)
  static final GlobalKey drawerKey = GlobalKey();

  // Cycle Card Key
  static final GlobalKey cardCycleKey = GlobalKey();

  // Price Card Keys
  static final GlobalKey priceCardKey = GlobalKey();
  static final GlobalKey allPricesButtonKey = GlobalKey();
  static final GlobalKey settingsIconKey = GlobalKey();

  // Tools Section Keys
  static final GlobalKey toolsSectionKey = GlobalKey();
  static final GlobalKey toolsTitleKey = GlobalKey();
  static final GlobalKey viewAllKey = GlobalKey();
  static final GlobalKey toolsScrollViewKey = GlobalKey();

  static TutorialCoachMark? _tutorial;

  static Future<void> showTutorial(
    BuildContext context, {
    VoidCallback? onTutorialComplete,
  }) {
    // التحقق من أن المستخدم لم يشاهد الـ tutorial من قبل
    final myServices = Get.find<MyServices>();
    final hasSeenTutorial =
        myServices.getStorage.read<bool>(StorageKeys.homeTutorialSeen) ?? false;

    // إظهار الشرح إذا لم يشاهده من قبل أو إذا كان في وضع الاختبار
    final shouldShowTutorial =
        !hasSeenTutorial || TestModeManager.shouldShowTutorialEveryTime;

    if (!shouldShowTutorial) {
      return Future.value();
    }

    // طلب الأذونات أولاً قبل عرض الشرح
    final PermissionController permissionController =
        Get.isRegistered<PermissionController>()
            ? Get.find<PermissionController>()
            : Get.put(PermissionController());

    return _requestPermissions(permissionController).then((canProceed) async {
      if (!canProceed) {
        // Permissions step indicates we should not proceed now
        return;
      }

      // Give the UI a frame and a small delay to ensure dialogs/snackbars are closed
      await _waitNextFrame();
      await _waitForUiToSettle();
      await _waitSnackbarsToClose();

      // ignore: use_build_context_synchronously
      if (!context.mounted) return;

      final targets = _createTargets(
        context,
        onTutorialComplete: onTutorialComplete,
      );

      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      _tutorial = TutorialCoachMark(
        targets: targets,
        colorShadow: Colors.black.withValues(alpha: 0.3),
        textSkip: 'تخطي',
        textStyleSkip: TextStyle(color: isDark ? Colors.white : Colors.black),
        paddingFocus: 0, // أصغر قيمة ممكنة
        opacityShadow: 0.3,
        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        onFinish: () {
          _completeTutorial(onTutorialComplete: onTutorialComplete);
          return true;
        },
        onSkip: () {
          _completeTutorial(onTutorialComplete: onTutorialComplete);
          return true;
        },
      );

      _tutorial?.show(context: context);
    });
  }

  static Future<bool> _requestPermissions(
    PermissionController permissionController,
  ) async {
    // Request notification, then location, sequentially
    await permissionController.checkAndRequestNotificationPermission();

    await permissionController.checkAndRequestLocationPermission();

    // If any permission flow led to a snackbar (e.g., permanently denied), wait for it or skip tutorial
    if (Get.isSnackbarOpen) {
      // Do not proceed while snackbar is shown; let the user act first
      return false;
    }

    // Proceed regardless of grant states (tutorial is informational),
    // but you can choose to enforce required permissions by returning (notificationGranted && locationGranted)
    return true;
  }

  static Future<void> _waitNextFrame() async {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
    return completer.future;
  }

  static Future<void> _waitForUiToSettle() async {
    // Brief delay so dialogs/transitions finish before tutorial overlay
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }

  static Future<void> _waitSnackbarsToClose() async {
    // Poll briefly; if a snackbar is open, wait until it closes or timeout
    const Duration step = Duration(milliseconds: 100);
    const int maxSteps = 20; // up to 2s
    int steps = 0;
    while (Get.isSnackbarOpen && steps < maxSteps) {
      await Future<void>.delayed(step);
      steps++;
    }
  }

  static List<TargetFocus> _createTargets(
    BuildContext context, {
    VoidCallback? onTutorialComplete,
  }) {
    final List<TargetFocus> targets = [
      buildTutorialTarget(
        id: 'drawer',
        key: drawerKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'القائمة الجانبية',
            description:
                'اضغط على أيقونة القائمة لفتح القائمة الجانبية\n\n**ماذا تجد فيها؟** 📋\n'
                '• معلومات عن التطبيق وإصداره\n'
                '• إعدادات الحساب والخصوصية\n'
                '• الدعم والاتصال\n'
                '• روابط التواصل الاجتماعي\n\n'
                'يمكنك الرجوع إليها في أي وقت من أيقونة القائمة',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'all_prices_button',
        key: allPricesButtonKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'زر جميع الأسعار',
            description:
                'هذا الزر يفتح صفحة تحتوي على جميع أسعار البورصة\n\nأسعار الفراخ بأنواعها المختلفة 📊\nأسعار العلف والمواد الغذائية 🌾\n\nيمكنك من خلاله مراجعة جميع الأسعار في مكان واحد',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'settings_icon',
        key: settingsIconKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'أيقونة الإعدادات',
            description:
                'هذه الأيقونة تفتح صفحة تخصيص الأسعار\n\n**تخصيص الأسعار المعروضة** ⚙️\nاختيار أنواع الأسعار التي تريد رؤيتها ✅\nإدارة الإشعارات للأسعار المهمة لديك 🔔',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'price_card',
        key: priceCardKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'بطاقة الأسعار الحالية',
            description:
                'هذه البطاقة الكاملة تحتوي على جميع الاسعار التي يتم تخصصها\n\n'
                '**التحديث التلقائي** 🔄\nالأسعار محدثة باستمرار من البورصة المحلية لضمان دقة المعلومات\n\n'
                '**سجل الأسعار** 📈\nاضغط على أي صف سعر لفتح سجل الأسعار التاريخي لهذا النوع ومعرفة تطور الأسعار عبر الزمن\n\n'
                '**سهولة الوصول** 📱\nيمكنك مراجعة هذه الأسعار في أي وقت لاتخاذ قرارات مدروسة',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'card_cycle',
        key: cardCycleKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'بطاقة الدورة الحالية',
            description:
                'هذه البطاقة تعرض دورات التربية النشطة\n\n'
                '**مراحل الدورة** 📅\n'
                '• تحضين → تسمين → بيع\n\n'
                '**ما الذي تراه؟** 📊\n'
                'عمر الدورة، عدد الكتاكيت، النافق، المرحلة الحالية، وإجمالي المصروفات. '
                'يمكنك التمرير بين الدورات إذا كان لديك أكثر من دورة.\n\n'
                'اضغط على البطاقة للانتقال إلى تفاصيل الدورة أو إضافة دورة جديدة.',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'tools_section',
        key: toolsSectionKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'قسم الأدوات المساعدة',
            description:
                'هذا القسم يحتوي على جميع الأدوات المفيدة للتربية\n\n يمكنك التمرير لرؤية المزيد من الأدوات',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'view_all_button',
        key: viewAllKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'زر عرض الكل',
            description:
                'اضغط على "عرض الكل" للانتقال إلى صفحة تحتوي على جميع الأدوات المتاحة في التطبيق ستجد هناك',
            actionButtons: [
              TutorialActionButtons.finish(
                onPressed: controller.next,
                label: 'انهاء',
              ),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
    ];

    return targets;
  }

  static void _completeTutorial({VoidCallback? onTutorialComplete}) {
    final myServices = Get.find<MyServices>();

    // حفظ حالة المشاهدة فقط إذا لم يكن في وضع الاختبار
    if (!TestModeManager.shouldShowTutorialEveryTime) {
      myServices.getStorage.write(StorageKeys.homeTutorialSeen, true);
    }

    // استدعاء callback إذا كان موجود
    onTutorialComplete?.call();
  }

  // دالة لإعادة تعيين الـ tutorial (للاستخدام في الاختبار)
  static void resetTutorial() {
    final myServices = Get.find<MyServices>();
    myServices.getStorage.remove(StorageKeys.homeTutorialSeen);
  }

  // دالة لإلغاء الشرح عند الخروج من الصفحة
  static void cancelTutorial() {
    try {
      if (_tutorial != null) {
        // محاولة إلغاء الشرح باستخدام skip() إذا كان متاحاً
        try {
          _tutorial?.skip();
        } catch (_) {
          // إذا لم يعمل skip()، ببساطة نزيل المرجع
        }
        _tutorial = null;
      }
    } catch (_) {
      _tutorial = null;
    }
  }
}
