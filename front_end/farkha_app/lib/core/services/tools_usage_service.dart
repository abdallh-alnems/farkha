import 'package:flutter/foundation.dart';

import '../class/crud.dart';
import '../constant/id/api.dart';

class ToolsUsageService {
  static final Crud _crud = Crud();

  /// Fire-and-forget — never blocks the UI; failures are silently swallowed.
  static void recordUsage(int toolId) {
    _crud.postData(Api.recordToolsUsage, {'tool_id': '$toolId'}).then((result) {
      result.fold(
        (failure) => debugPrint('⚠️ tools_usage failed: $failure'),
        (_) => debugPrint('📈 tools_usage recorded: $toolId'),
      );
    });
  }
}
