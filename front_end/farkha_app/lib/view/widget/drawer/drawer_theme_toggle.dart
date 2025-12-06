import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/dark_light_service.dart';

class DrawerThemeToggle extends StatelessWidget {
  const DrawerThemeToggle({super.key});

  bool _getIsDark(BuildContext context, ThemeMode currentMode) {
    if (currentMode == ThemeMode.dark) {
      return true;
    } else if (currentMode == ThemeMode.light) {
      return false;
    } else {
      // إذا كان system، نتحقق من الوضع الفعلي للهاتف
      final Brightness systemBrightness =
          MediaQuery.of(context).platformBrightness;
      return systemBrightness == Brightness.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DarkLightService themeService = Get.find<DarkLightService>();
    final colorScheme = Theme.of(context).colorScheme;
    const Color sunColor = Color(0xFFFFA500); // لون برتقالي/أصفر للشمس
    const Color moonColor = Color(0xFFC0C0C0); // لون فضي للقمر

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() {
        final ThemeMode currentMode = themeService.themeMode.value;
        final bool isDark = _getIsDark(context, currentMode);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.light_mode,
              color: isDark ? sunColor.withValues(alpha: 0.4) : sunColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Switch(
              value: isDark,
              onChanged: (_) => themeService.toggleTheme(),
              activeThumbColor: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.dark_mode,
              color: isDark ? moonColor : moonColor.withValues(alpha: 0.4),
              size: 24,
            ),
          ],
        );
      }),
    );
  }
}


