import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../constant/theme/colors.dart';

class SnackbarMessage {
  static bool _isShowing = false;

  static void show(
    BuildContext context,
    String message, {
    required IconData icon,
  }) {
    // Ensure context is still mounted and Overlay is available
    if (!context.mounted) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    if (_isShowing) {
      _isShowing = false;
    }

    _isShowing = true;
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();

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
                            color: AppColors.primaryColor,
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

    Future.delayed(const Duration(seconds: 3), () {
      isVisible.value = false;

      Future.delayed(const Duration(milliseconds: 300), () {
        overlayEntry?.remove();
        _isShowing = false;
      });
    });
  }
}
