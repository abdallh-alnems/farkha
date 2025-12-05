import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/theme/colors.dart';
import '../../../../logic/controller/tools_controller/broiler_controller.dart';
import '../../../../logic/controller/weather_controller.dart';

class DetailsBroiler extends GetView<BroilerController> {
  const DetailsBroiler({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.darkSurfaceElevatedColor
                : AppColors.lightSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark
                  ? AppColors.darkOutlineColor.withOpacity(0.5)
                  : AppColors.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            context: context,
            label: "العدد",
            value: controller.chickensCountController.text,
            icon: Icons.numbers,
          ),
          _buildVerticalDivider(context),
          _buildDetailItem(
            context: context,
            label: "العمر",
            value: controller.selectedChickenAge.value?.toString() ?? "-",
            icon: Icons.calendar_today,
            suffix: "يوم",
          ),
          _buildVerticalDivider(context),
          GetBuilder<WeatherController>(
            builder:
                (_) => _buildDetailItem(
                  context: context,
                  label: "الموقع",
                  value: controller.weatherLocationShort,
                  icon: Icons.location_on,
                  isLocation: true,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    String? suffix,
    bool isLocation = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          if (isLocation)
            SizedBox(
              width: 100,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(text: value),
                  if (suffix != null)
                    TextSpan(
                      text: " $suffix",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Theme.of(context).colorScheme.outline.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
