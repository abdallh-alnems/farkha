import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutoScrollController extends GetxController {
  final ScrollController scrollController = ScrollController();
  Timer? autoScrollTimer;
  bool isUserScrolling = false;
  double scrollOffset = 0.0;
  bool isReversing = false;
  bool isInitialized = false;
  double lastScrollPosition = 0.0;

  @override
  void onInit() {
    super.onInit();
    print("AutoScrollController initialized"); // للتأكد من التهيئة

    // إضافة listener للكشف عن التمرير اليدوي
    scrollController.addListener(_onScroll);

    // بدء الأسكرول التلقائي فوراً بدون تأخير
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("Post frame callback executed"); // للتأكد من تنفيذ الكولباك
      isInitialized = true;
      startAutoScroll();
    });
  }

  @override
  void onClose() {
    autoScrollTimer?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!isInitialized) return;

    double currentPosition = scrollController.position.pixels;

    // الكشف عن التمرير اليدوي
    if ((currentPosition - lastScrollPosition).abs() > 5) {
      // المستخدم يقوم بالتمرير يدوياً
      if (!isUserScrolling) {
        print("User started manual scrolling");
        isUserScrolling = true;
        stopAutoScroll();
      }
    }

    lastScrollPosition = currentPosition;
  }

  void startAutoScroll() {
    if (!isInitialized) return;

    print("Starting auto scroll..."); // للتأكد من أن الدالة تعمل

    autoScrollTimer?.cancel();
    autoScrollTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      // Slower speed
      if (!isUserScrolling && isInitialized) {
        try {
          if (!scrollController.hasClients) {
            return;
          }

          final maxScroll = scrollController.position.maxScrollExtent;

          // التأكد من وجود محتوى للأسكرول
          if (maxScroll <= 0) {
            return;
          }

          // تهيئة scrollOffset إذا كان صفر
          if (scrollOffset == 0.0) {
            scrollOffset = scrollController.position.pixels;
          }

          if (isReversing) {
            // التحرك للخلف (نحو البداية)
            scrollOffset -= 1.0; // Slower speed
            if (scrollOffset <= 0) {
              scrollOffset = 0.0;
              isReversing = false;
            }
          } else {
            // التحرك للأمام (نحو النهاية)
            scrollOffset += 1.0; // Slower speed
            if (scrollOffset >= maxScroll) {
              scrollOffset = maxScroll;
              isReversing = true;
            }
          }

          // تطبيق الحركة مباشرة
          scrollController.jumpTo(scrollOffset);
        } catch (e) {
          print("Error in auto scroll: $e"); // للتأكد من الأخطاء
          return;
        }
      }
    });
  }

  void stopAutoScroll() {
    autoScrollTimer?.cancel();
    autoScrollTimer = null;
  }

  void pauseAutoScroll() {
    isUserScrolling = true;
    stopAutoScroll();

    // لا يعود الأسكرول التلقائي للعمل بعد التفاعل اليدوي
    // Timer(const Duration(seconds: 3), () {
    //   isUserScrolling = false;
    //   startAutoScroll();
    // });
  }

  // دالة لإعادة تشغيل الأسكرول التلقائي يدوياً إذا احتجت لذلك
  void resumeAutoScroll() {
    isUserScrolling = false;
    startAutoScroll();
  }
}
