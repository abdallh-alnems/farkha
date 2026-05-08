import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constant/storage_keys.dart';
import '../../../core/constant/theme/theme.dart';
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

class FeasibilityStudyScreen extends StatefulWidget {
  const FeasibilityStudyScreen({super.key});

  @override
  State<FeasibilityStudyScreen> createState() => _FeasibilityStudyState();
}

class _FeasibilityStudyState extends State<FeasibilityStudyScreen> {
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
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorialIfNeeded();
    });
  }

  void _showTutorialIfNeeded() {
    final hasSeenTutorial =
        myServices.getStorage.read<bool>(StorageKeys.feasibilityTutorialSeen) ?? false;

    final shouldShowTutorial =
        !hasSeenTutorial || TestModeManager.shouldShowTutorialEveryTime;

    if (shouldShowTutorial) {
      setState(() {
        _isTutorialActive = true;
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
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
    UsageTipsDialog.showDialogIfNotShown(StorageKeys.feasibilityStudyDialog);
  }

  // ignore: unused_element
  static void resetTutorialForTesting() {
    final myServices = Get.find<MyServices>();
    myServices.getStorage.remove(StorageKeys.feasibilityTutorialSeen);
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
    logToolPageViewOnce(widgetType: FeasibilityStudyScreen, toolId: 14);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (_isTutorialActive) {
          FeasibilityTutorial.cancelTutorial();
          setState(() {
            _isTutorialActive = false;
          });
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(text: 'دراسة جدوى', favoriteToolName: 'دراسة جدوى'),
        body: Container(
          decoration: isDark
              ? null
              : BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.surface,
                      AppColors.appBackGroundColor,
                    ],
                    stops: const [0.0, 0.15],
                  ),
                ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: 4.h,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        if (!_isTutorialActive) ...[
                          const AdNativeWidget(),
                          SizedBox(height: 16.h),
                        ] else
                          SizedBox(height: 16.h),

                        InputsSection(
                          formKey: _formKey,
                          onAfterCalculate: _scrollToTop,
                        ),

                        const ResultsSection(),

                        SizedBox(height: 20.h),
                        const RelatedArticlesSection(relatedArticleIds: [20]),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _isTutorialActive ? null : const AdBannerWidget(),
      ),
    );
  }
}
