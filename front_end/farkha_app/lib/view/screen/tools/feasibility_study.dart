import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/functions/tool_page_view.dart';
import '../../../core/services/initialization.dart';
import '../../../core/services/test_mode_manager.dart';
import '../../../core/shared/usage_tips_dialog.dart';
import '../../../logic/controller/tools_controller/feasibility_study_controller.dart';
import '../../widget/ad/banner.dart';
import '../../widget/ad/native.dart';
import '../../widget/appbar/custom_appbar.dart';
import '../../widget/tools/feasibility_study/inputs_section.dart';
import '../../widget/tools/feasibility_study/results_section.dart';
import '../../widget/tools/related_articles_section.dart';
import '../../widget/tutorial/feasibility_tutorial.dart';

class FeasibilityStudy extends StatefulWidget {
  const FeasibilityStudy({super.key});

  @override
  State<FeasibilityStudy> createState() => _FeasibilityStudyState();
}

class _FeasibilityStudyState extends State<FeasibilityStudy> {
  final FeasibilityController controller = Get.put(FeasibilityController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  bool _isTutorialActive = false;
  bool _hasShownUsageTips = false;
  MyServices myServices = Get.find();

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // إظهار الـ tutorial بعد بناء الـ widgets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorialIfNeeded();
    });
  }

  void _showTutorialIfNeeded() {
    // التحقق من أن المستخدم لم يشاهد الـ tutorial من قبل
    final hasSeenTutorial =
        myServices.getStorage.read<bool>('feasibility_tutorial_seen') ?? false;

    // إظهار الشرح إذا لم يشاهده من قبل أو إذا كان في وضع الاختبار
    final shouldShowTutorial =
        !hasSeenTutorial || TestModeManager.shouldShowTutorialEveryTime;

    if (shouldShowTutorial) {
      // إخفاء الاعلانات فوراً قبل إظهار الشرح
      setState(() {
        _isTutorialActive = true;
      });

      // تأخير قصير للتأكد من إخفاء الاعلانات
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        // إظهار الـ tutorial مع callback عند الانتهاء
        FeasibilityTutorial.showTutorial(
          // ignore: use_build_context_synchronously
          context,
          onTutorialComplete: () {
            if (mounted) {
              setState(() {
                _isTutorialActive = false;
              });
            }
            _showUsageTipsDialog();
          },
        );
      });
    } else {
      _showUsageTipsDialog();
    }
  }

  void _showUsageTipsDialog() {
    if (_hasShownUsageTips) {
      return;
    }
    _hasShownUsageTips = true;
    UsageTipsDialog.showDialogIfNotShown('feasibilityStudyDialog');
  }

  // دالة لإعادة تعيين الـ tutorial للاختبار
  // ignore: unused_element
  static void resetTutorialForTesting() {
    final myServices = Get.find<MyServices>();
    myServices.getStorage.remove('feasibility_tutorial_seen');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_isTutorialActive) {
      FeasibilityTutorial.cancelTutorial();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logToolPageViewOnce(widgetType: FeasibilityStudy, toolName: 'دراسة جدوي');

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // إلغاء الشرح عند الضغط على زر الرجوع
        if (_isTutorialActive) {
          FeasibilityTutorial.cancelTutorial();
          setState(() {
            _isTutorialActive = false;
          });
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(text: 'دراسة جدوي', favoriteToolName: 'دراسة جدوي'),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        // إظهار الإعلان فقط إذا لم يكن الـ tutorial نشط
                        if (!_isTutorialActive) ...[
                          const AdNativeWidget(),
                          const SizedBox(height: 19),
                        ] else
                          const SizedBox(height: 19),

                        // Inputs Section (includes prices and default values)
                        InputsSection(
                          formKey: _formKey,
                          onAfterCalculate: _scrollToTop,
                        ),

                        // Results Section
                        const ResultsSection(),

                        const SizedBox(height: 24),
                        const RelatedArticlesSection(relatedArticleIds: [20]),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 17),
          ],
        ),
        bottomNavigationBar: _isTutorialActive ? null : const AdBannerWidget(),
      ),
    );
  }
}
