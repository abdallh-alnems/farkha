import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/theme/theme.dart';

class ToolInputCard extends StatelessWidget {
  final Widget child;

  const ToolInputCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimens.borderLg,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.4),
        ),
        boxShadow: isDark
            ? null
            : [AppElevation.shadow(opacity: 0.06)],
      ),
      child: child,
    );
  }
}
