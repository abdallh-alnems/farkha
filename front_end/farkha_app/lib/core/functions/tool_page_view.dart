import 'package:flutter/material.dart';

import '../services/tools_usage_service.dart';

final Map<int, DateTime> _lastLogged = {};

void logToolPageViewOnce({required Type widgetType, required int toolId}) {
  final now = DateTime.now();
  final lastLog = _lastLogged[toolId];
  if (lastLog != null && now.difference(lastLog).inSeconds < 2) return;
  _lastLogged[toolId] = now;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    ToolsUsageService.recordUsage(toolId);
  });
}
