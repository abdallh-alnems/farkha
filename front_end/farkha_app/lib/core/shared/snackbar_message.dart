import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../constant/theme/colors.dart';

enum SnackbarType { error, success, info, warning }

class SnackbarMessage {
  static bool _isShowing = false;

  /// Show a snackbar message with custom icon and color
  static void show(
    BuildContext? context,
    String message, {
    required IconData icon,
    Color? backgroundColor,
    Duration? duration,
  }) {
    final ctx = context ?? Get.key.currentContext ?? Get.context;
    if (ctx == null || !ctx.mounted) return;

    final overlay = Overlay.maybeOf(ctx);
    if (overlay == null) return;

    if (_isShowing) {
      _isShowing = false;
    }

    _isShowing = true;
    ScaffoldMessenger.maybeOf(ctx)?.clearSnackBars();

    final bgColor = backgroundColor ?? AppColors.primaryColor;
    final snackDuration = duration ?? const Duration(seconds: 3);

    OverlayEntry? overlayEntry;
    final ValueNotifier<bool> isVisible = ValueNotifier<bool>(false);

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: isVisible,
                builder: (context, visible, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: visible ? Curves.elasticOut : Curves.easeIn,
                    transform:
                        Matrix4.identity()
                          ..scaleByVector3(
                            Vector3(
                              visible ? 1.0 : 0.8,
                              visible ? 1.0 : 0.8,
                              1.0,
                            ),
                          )
                          ..translateByVector3(
                            Vector3(0.0, visible ? 0.0 : 200.0, 0.0),
                          ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: visible ? 1.0 : 0.0,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, color: Colors.white, size: 21),
                              const SizedBox(width: 13),
                              Text(
                                message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isVisible.value = true;
    });

    Future.delayed(snackDuration, () {
      isVisible.value = false;

      Future.delayed(const Duration(milliseconds: 300), () {
        overlayEntry?.remove();
        _isShowing = false;
      });
    });
  }

  /// Show an error message
  static void showError(
    BuildContext? context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Show a success message
  static void showSuccess(
    BuildContext? context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
      duration: duration ?? const Duration(seconds: 2),
    );
  }

  /// Show an info message
  static void showInfo(
    BuildContext? context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Show a warning message
  static void showWarning(
    BuildContext? context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Colors.orange,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
