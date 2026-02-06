import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/analytics_service.dart';

void logToolPageViewOnce({required Type widgetType, required String toolName}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final analyticsService = Get.find<AnalyticsService>();
    analyticsService.logToolPageView(toolName: toolName);
  });
}
