import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../core/constant/strings/app_strings.dart';
import '../../../../core/constant/storage_keys.dart';
import '../../../../core/services/initialization.dart';
import '../../../../core/services/test_mode_manager.dart';
import 'widgets/tutorial_action_buttons.dart';
import 'widgets/tutorial_content_card.dart';
import 'widgets/tutorial_target_factory.dart';

class CustomizePricesTutorial {
  // GlobalKeys for tutorial targets
  static final GlobalKey typeNameKey = GlobalKey();
  static final GlobalKey notificationIconKey = GlobalKey();
  static final GlobalKey selectionIndicatorKey = GlobalKey();

  static TutorialCoachMark? _tutorial;

  static Future<void> showTutorial(
    BuildContext context, {
    VoidCallback? onTutorialComplete,
  }) {
    // التحقق من أن المستخدم لم يشاهد الـ tutorial من قبل
    final myServices = Get.find<MyServices>();
    final hasSeenTutorial =
        myServices.getStorage.read<bool>(StorageKeys.customizePricesTutorialSeen) ??
        false;

    // إظهار الشرح إذا لم يشاهده من قبل أو إذا كان في وضع الاختبار
    final shouldShowTutorial =
        !hasSeenTutorial || TestModeManager.shouldShowTutorialEveryTime;

    if (!shouldShowTutorial) {
      return Future.value();
    }

    final targets = _createTargets(
      context,
      onTutorialComplete: onTutorialComplete,
    );

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    _tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withValues(alpha: 0.3),
      textSkip: AppStrings.skip,
      textStyleSkip: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
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
    return Future.value();
  }

  static List<TargetFocus> _createTargets(
    BuildContext context, {
    VoidCallback? onTutorialComplete,
  }) {
    return [
      buildTutorialTarget(
        id: 'type_name',
        key: typeNameKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'اسم العنصر',
            description:
                'اضغط على اسم العنصر لتفعيل أو إلغاء تفعيل\n\n**العرض في الصفحة الرئيسية** 📱\nإظهار السعر في بطاقة الأسعار ✅\nإخفاء السعر من البطاقة ❌\n\n**الإشعارات** 🔔\nتفعيل التنبيهات عند تغيير السعر ✅\nإلغاء التنبيهات ❌\n\nالضغط على الاسم يتحكم في كلا الوظيفتين معاً',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'notification_icon',
        key: notificationIconKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'أيقونة الإشعارات',
            description:
                'هذه الأيقونة تتحكم في الإشعارات فقط\n\n**تفعيل الإشعارات** 🔔\nاستقبال تنبيهات عند تغيير السعر ✅\nإشعارات فورية على الهاتف 📱\n\n**إلغاء الإشعارات** 🔕\nعدم استقبال أي تنبيهات ❌\nتوقف التنبيهات لهذا السعر 🔇\n\nيمكن تفعيل الإشعارات حتى لو لم يكن السعر ظاهراً في الصفحة الرئيسية',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'selection_indicator',
        key: selectionIndicatorKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'مؤشر الاختيار',
            description:
                'هذا المؤشر يتحكم في عرض السعر في الصفحة الرئيسية\n\n**تفعيل العرض** ✅\nإظهار السعر في بطاقة الأسعار 📱\nرؤية السعر الحالي بسهولة 👁️\n\n**إلغاء العرض** ❌\nإخفاء السعر من البطاقة 🚫\nعدم ظهوره في الصفحة الرئيسية 📋',
            actionButtons: [
              TutorialActionButtons.finish(onPressed: controller.skip),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
    ];
  }

  static void _completeTutorial({VoidCallback? onTutorialComplete}) {
    final myServices = Get.find<MyServices>();

    // حفظ حالة المشاهدة فقط إذا لم يكن في وضع الاختبار
    if (!TestModeManager.shouldShowTutorialEveryTime) {
      myServices.getStorage.write(StorageKeys.customizePricesTutorialSeen, true);
    }

    // استدعاء callback إذا كان موجود
    onTutorialComplete?.call();
  }

  // دالة لإعادة تعيين الـ tutorial (للاستخدام في الاختبار)
  static void resetTutorial() {
    final myServices = Get.find<MyServices>();
    myServices.getStorage.remove(StorageKeys.customizePricesTutorialSeen);
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
