import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/package/dialogs/tool_explanation_dialog.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final VoidCallback? onAlertTap;
  final bool showIcon;
  final String? toolKey; // مفتاح الأداة لعرض الرسالة المناسبة

  const CustomAppBar({
    super.key,
    required this.text,
    this.onAlertTap,
    this.showIcon = true,
    this.toolKey,
  });

  // دالة عرض شرح الأداة
  void _showToolExplanation() {
    if (toolKey != null) {
      ToolExplanationDialog.showDialog(toolKey: toolKey!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(color: Colors.black),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 27,
        ),
        onPressed: () => Get.back(),
        splashRadius: 24,
      ),
      actions:
          showIcon
              ? [
                Padding(
                  padding: const EdgeInsets.only(right: 17),
                  child: GestureDetector(
                    onTap: onAlertTap ?? _showToolExplanation,
                    child: const Icon(
                      Icons.priority_high,
                      color: Colors.black,
                      size: 21,
                    ),
                  ),
                ),
              ]
              : null,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
