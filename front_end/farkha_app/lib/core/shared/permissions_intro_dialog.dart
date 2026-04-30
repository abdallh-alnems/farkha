import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/theme/colors.dart';
import '../services/dark_light_service.dart';

/// Accent colors used only in these intro dialogs.
const Color _introLocationAccent = Color(0xFF0D9488);
const Color _introNotificationAccent = Color(0xFFEA580C);
const Color _introThemeAccent = Color(0xFF7C3AED);

/// Step 1: Location permission intro.
class LocationIntroDialog extends StatelessWidget {
  const LocationIntroDialog({
    super.key,
    required this.onEnable,
    required this.onLater,
  });

  final Future<void> Function() onEnable;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    return _IntroDialogLayout(
      icon: Icons.location_on_outlined,
      accentColor: _introLocationAccent,
      title: 'الوصول إلى الموقع',
      message:
          'التطبيق يريد الوصول إلى موقعك لعرض الطقس والخدمات المرتبطة بموقعك.',
      onEnable: onEnable,
      onLater: onLater,
    );
  }
}

/// Step 2: Notification permission intro.
class NotificationIntroDialog extends StatelessWidget {
  const NotificationIntroDialog({
    super.key,
    required this.onEnable,
    required this.onLater,
  });

  final Future<void> Function() onEnable;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    return _IntroDialogLayout(
      icon: Icons.notifications_active_outlined,
      accentColor: _introNotificationAccent,
      title: 'الإشعارات',
      message:
          'نحتاج إلى تفعيل الإشعارات لإرسال تحديثات أسعار الدجاج والأخبار المهمة.',
      onEnable: onEnable,
      onLater: onLater,
    );
  }
}

/// Step 3: Theme selection for the app.
class ThemeIntroDialog extends StatelessWidget {
  const ThemeIntroDialog({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bodyTextColor =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF424242);
    const accentColor = _introThemeAccent;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.palette_outlined, size: 56, color: accentColor),
            const SizedBox(height: 16),
            Text(
              'اختر مظهر التطبيق',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'اختر الوضع المناسب لك: فاتح، غامق، أو حسب مظهر الهاتف.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: bodyTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _ThemeChoiceRow(onDone: onDone, accentColor: accentColor),
          ],
        ),
      ),
    );
  }
}

class _ThemeChoiceRow extends StatelessWidget {
  const _ThemeChoiceRow({required this.onDone, required this.accentColor});

  final VoidCallback onDone;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<DarkLightService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ThemeOption(
          icon: Icons.light_mode,
          label: 'فاتح',
          themeMode: ThemeMode.light,
          currentMode: themeService.themeMode.value,
          onSelect: () {
            themeService.applyTheme(ThemeMode.light);
            Get.back<void>();
            onDone();
          },
          isDark: isDark,
          accentColor: accentColor,
        ),
        const SizedBox(width: 12),
        _ThemeOption(
          icon: Icons.dark_mode,
          label: 'غامق',
          themeMode: ThemeMode.dark,
          currentMode: themeService.themeMode.value,
          onSelect: () {
            themeService.applyTheme(ThemeMode.dark);
            Get.back<void>();
            onDone();
          },
          isDark: isDark,
          accentColor: accentColor,
        ),
        const SizedBox(width: 12),
        _ThemeOption(
          icon: Icons.brightness_auto,
          label: 'حسب مظهر الهاتف',
          themeMode: ThemeMode.system,
          currentMode: themeService.themeMode.value,
          onSelect: () {
            themeService.applyTheme(ThemeMode.system);
            Get.back<void>();
            onDone();
          },
          isDark: isDark,
          accentColor: accentColor,
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.themeMode,
    required this.currentMode,
    required this.onSelect,
    required this.isDark,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final ThemeMode themeMode;
  final ThemeMode currentMode;
  final VoidCallback onSelect;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMode == themeMode;
    final borderColor =
        isSelected
            ? accentColor
            : (isDark
                ? AppColors.darkOutlineColor
                : AppColors.lightOutlineColor);

    return Expanded(
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: accentColor),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      isSelected
                          ? accentColor
                          : (isDark
                              ? AppColors.darkSecondaryColor
                              : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroDialogLayout extends StatelessWidget {
  const _IntroDialogLayout({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.message,
    required this.onEnable,
    required this.onLater,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String message;
  final Future<void> Function() onEnable;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurfaceColor : AppColors.lightSurfaceColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bodyTextColor =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF424242);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: surfaceColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: accentColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: bodyTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Get.back<void>();
                  await onEnable();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('تفعيل'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.back<void>();
                onLater();
              },
              child: Text('لاحقاً', style: TextStyle(color: bodyTextColor)),
            ),
          ],
        ),
      ),
    );
  }
}
