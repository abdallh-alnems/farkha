import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/shared/tools/tool_input_card.dart';
import '../ad/banner.dart';
import '../ad/native.dart';
import '../appbar/custom_appbar.dart';
import 'tools_button.dart';

class ToolPageScaffold extends StatelessWidget {
  final String title;
  final Widget inputChild;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final List<Widget> footerSections;

  const ToolPageScaffold({
    super.key,
    required this.title,
    required this.inputChild,
    this.buttonText,
    this.onButtonPressed,
    this.footerSections = const [],
  });

  @override
  Widget build(BuildContext context) {
    final hasButton = buttonText != null && onButtonPressed != null;

    return Scaffold(
      appBar: CustomAppBar(text: title, favoriteToolName: title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolInputCard(child: inputChild),
              SizedBox(height: 12.h),
              const AdNativeWidget(),
              SizedBox(height: 12.h),
              if (hasButton) ...[
                ToolsButton(text: buttonText!, onPressed: onButtonPressed!),
                SizedBox(height: 14.h),
              ],
              ...footerSections,
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
