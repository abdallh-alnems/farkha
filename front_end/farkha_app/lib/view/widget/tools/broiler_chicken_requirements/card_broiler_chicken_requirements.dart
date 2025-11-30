import 'package:flutter/material.dart';

import '../../../../core/constant/theme/colors.dart';

class CardBroilerChickenRequirements extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const CardBroilerChickenRequirements({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.gradientColors = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> colors =
        gradientColors.isNotEmpty
            ? gradientColors
            : [
              AppColors.primaryColor.withOpacity(0.8),
              AppColors.primaryColor.withOpacity(0.5),
            ];
    final bool useGradient = gradientColors.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient:
            useGradient
                ? LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: useGradient 
            ? null 
            : (isDark ? AppColors.darkSurfaceElevatedColor : AppColors.lightSurfaceColor),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              (useGradient
                  ? colors.last.withOpacity(0.25)
                  : (isDark 
                      ? AppColors.darkOutlineColor.withOpacity(0.5)
                      : AppColors.primaryColor.withOpacity(0.12))),
          width: 1.5,
        ),
        boxShadow: useGradient || isDark ? [
          BoxShadow(
            color:
                (useGradient
                    ? colors.last.withOpacity(0.2)
                    : Colors.transparent),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ] : [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconBadge(icon: icon, useGradient: useGradient),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color:
                  useGradient
                      ? Colors.white.withOpacity(0.95)
                      : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: useGradient ? Colors.white : colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.2,
              fontSize: 16,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:
                    (useGradient
                        ? Colors.white.withOpacity(0.18)
                        : colorScheme.primary.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      useGradient
                          ? Colors.white.withOpacity(0.9)
                          : colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.useGradient});
  final IconData icon;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color:
            useGradient
                ? Colors.white.withOpacity(0.22)
                : colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              useGradient
                  ? Colors.white.withOpacity(0.28)
                  : colorScheme.primary.withOpacity(0.18),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Icon(
        icon,
        color: useGradient ? Colors.white : colorScheme.primary,
        size: 20,
      ),
    );
  }
}
