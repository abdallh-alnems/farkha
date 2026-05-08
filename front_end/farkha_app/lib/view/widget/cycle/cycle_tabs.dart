import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/handling_data.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';

class CycleDetailsOverlay extends StatelessWidget {
  final bool isDark;

  const CycleDetailsOverlay({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cycleCtrl = Get.find<CycleController>();

    return Obx(() {
      final status = cycleCtrl.cycleDetailsStatus.value;
      if (status == StatusRequest.loading ||
          status == StatusRequest.serverFailure ||
          status == StatusRequest.offlineFailure ||
          status == StatusRequest.failure) {
        return Positioned.fill(
          child: IgnorePointer(
            ignoring: status != StatusRequest.loading,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: (isDark
                          ? AppColors.darkBackGroundColor
                          : AppColors.lightPageBackgroundColor)
                      .withValues(alpha: 0.5),
                  child: HandlingDataView(
                    statusRequest: status,
                    widget: const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}

class CycleEndOverlay extends StatefulWidget {
  final bool isDark;

  const CycleEndOverlay({super.key, required this.isDark});

  @override
  State<CycleEndOverlay> createState() => _CycleEndOverlayState();
}

class _CycleEndOverlayState extends State<CycleEndOverlay> {
  @override
  Widget build(BuildContext context) {
    final cycleCtrl = Get.find<CycleController>();
    final isDark = widget.isDark;

    return Obx(() {
      final status = cycleCtrl.cycleEndStatus.value;
      if (status == StatusRequest.loading ||
          status == StatusRequest.serverFailure ||
          status == StatusRequest.offlineFailure ||
          status == StatusRequest.failure) {
        return Positioned.fill(
          child: IgnorePointer(
            ignoring: status != StatusRequest.loading,
            child: Container(
              color: (isDark
                      ? AppColors.darkBackGroundColor
                      : AppColors.lightPageBackgroundColor)
                  .withValues(alpha: 0.8),
              child: HandlingDataView(
                statusRequest: status,
                widget: const SizedBox.shrink(),
              ),
            ),
          ),
        );
      }

      if (status == StatusRequest.success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            cycleCtrl.cycleEndStatus.value = StatusRequest.none;
            if (mounted) {
              Get.offAllNamed<void>('/');
            }
          });
        });
      }

      return const SizedBox.shrink();
    });
  }
}
