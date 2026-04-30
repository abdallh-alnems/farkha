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

class FeasibilityTutorial {
  // Toggle Mode Keys
  static final GlobalKey toggleModeKey = GlobalKey();
  static final GlobalKey normalModeKey = GlobalKey();
  static final GlobalKey professionalModeKey = GlobalKey();

  // Stock Button Key
  static final GlobalKey stockButtonKey = GlobalKey();

  // Default Values Keys
  static final GlobalKey defaultValuesKey = GlobalKey();
  static final GlobalKey defaultValuesTitleKey = GlobalKey();
  static final GlobalKey defaultValuesButtonKey = GlobalKey();
  static final GlobalKey chickenCountKey = GlobalKey();
  static final GlobalKey financialAmountKey = GlobalKey();

  // Calculate Button Key
  static final GlobalKey calculateButtonKey = GlobalKey();

  // Price Boxes Keys
  static final GlobalKey chickenPriceKey = GlobalKey();
  static final GlobalKey feedPriceKey = GlobalKey();
  static final GlobalKey medicinePriceKey = GlobalKey();
  static final GlobalKey electricityPriceKey = GlobalKey();
  static final GlobalKey waterPriceKey = GlobalKey();
  static final GlobalKey laborPriceKey = GlobalKey();
  static final GlobalKey otherExpensesKey = GlobalKey();

  static TutorialCoachMark? _tutorial;

  static Future<void> showTutorial(
    BuildContext context, {
    VoidCallback? onTutorialComplete,
  }) {
    // التحقق من أن المستخدم لم يشاهد الـ tutorial من قبل
    final myServices = Get.find<MyServices>();
    final hasSeenTutorial =
        myServices.getStorage.read<bool>(StorageKeys.feasibilityTutorialSeen) ?? false;

    // إظهار الشرح إذا لم يشاهده من قبل أو إذا كان في وضع الاختبار
    final shouldShowTutorial =
        !hasSeenTutorial || TestModeManager.shouldShowTutorialEveryTime;

    if (!shouldShowTutorial) {
      return Future.value();
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final targets = _createTargets(
      context,
      onTutorialComplete: onTutorialComplete,
    );

    _tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withValues(alpha: 0.3), // تقليل لون الظل
      textSkip: AppStrings.skip,
      textStyleSkip: TextStyle(color: isDark ? Colors.white : Colors.black),
      paddingFocus: 0, // أصغر قيمة ممكنة
      opacityShadow: 0.3, // تقليل شفافية الظل
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
    final List<TargetFocus> targets = [
      buildTutorialTarget(
        id: 'toggle_mode_switch',
        key: toggleModeKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'زر التبديل - نوع الدراسة',
            description:
                'استخدم هذا الزر للتبديل بين:\n\nالوضع العادي للدراسة بناءً على عدد الفراخ (دراسة مبدئية وسريعة) 🔁\n\nالوضع الاحترافي للدراسة بناءً على المبلغ المالي (تحليل أكثر تفصيلاً ودقة) 💼',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'toggle_calculation_switch',
        key: defaultValuesKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'زر التبديل - نوع الحساب',
            description:
                'استخدم هذا الزر للتبديل بين:\n\nعدد الفراخ: أدخل عدد الفراخ التي تريد تربيتها 🐔\n\nمبلغ مالي: أدخل المبلغ المتاح للاستثمار 💰',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'price_boxes',
        key: chickenPriceKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'مربعات ادخال الأسعار',
            description:
                'ادخل الاسعار لعمل الدراسة \n\nسعر اللحم الأبيض 🍗\nسعر الكتكوت الأبيض 🐣\nسعر العلف بالطن 🌾\n\nيمكنك إدخال الأسعار التي تناسبك يدويًا أو استخدام زر متوسط البورصة للحصول على أسعار البورصة الحالية',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
    ];

    if (stockButtonKey.currentContext != null) {
      targets.add(
        buildTutorialTarget(
          id: 'stock_button',
          key: stockButtonKey,
          cardBuilder: (context, controller) {
            return TutorialContentCard(
              title: 'زر متوسط اسعار البورصة',
              description:
                  'اضغط على هذا الزر للحصول على متوسط الأسعار الحالية من البورصة تلقائياً 📊',
              actionButtons: [
                TutorialActionButtons.next(onPressed: controller.next),
                TutorialActionButtons.previous(onPressed: controller.previous),
              ],
            );
          },
        ),
      );
    }

    targets.addAll([
      buildTutorialTarget(
        id: 'default_values',
        key: defaultValuesTitleKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'مدخلات الدراسة',
            description:
                'هذه الحقول تمثل المدخلات الأساسية لحساب الدراسة\n\nعدد الفراخ أو المبلغ المالي الذي سيتم الاستثمار به 🐔💵\nوزن الفرخ المتوقع عند البيع ⚖️\nمعدل النفوق المتوقع خلال الدورة 📉\nالنثريات (التكاليف المتنوعة الإضافية) 🧾\nاستهلاك العلف لكل فرخ خلال الدورة 🌾\n\nأدخل القيم المناسبة لتحصل على نتائج دقيقة تعكس مشروعك.',
            actionButtons: [
              TutorialActionButtons.next(onPressed: controller.next),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
      buildTutorialTarget(
        id: 'default_values_button',
        key: defaultValuesButtonKey,
        cardBuilder: (context, controller) {
          return TutorialContentCard(
            title: 'زر تطبيق المدخلات الافتراضية',
            description:
                'اضغط على هذا الزر لتطبيق المدخلات الافتراضية المحددة مسبقاً ⚙️',
            actionButtons: [
              TutorialActionButtons.finish(onPressed: controller.skip),
              TutorialActionButtons.previous(onPressed: controller.previous),
            ],
          );
        },
      ),
    ]);

    return targets;
  }

  static void _completeTutorial({VoidCallback? onTutorialComplete}) {
    final myServices = Get.find<MyServices>();

    // حفظ حالة المشاهدة فقط إذا لم يكن في وضع الاختبار
    if (!TestModeManager.shouldShowTutorialEveryTime) {
      myServices.getStorage.write(StorageKeys.feasibilityTutorialSeen, true);
    }

    // استدعاء callback إذا كان موجود
    onTutorialComplete?.call();
  }

  // دالة لإعادة تعيين الـ tutorial (للاستخدام في الاختبار)
  static void resetTutorial() {
    final myServices = Get.find<MyServices>();
    myServices.getStorage.remove(StorageKeys.feasibilityTutorialSeen);
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
