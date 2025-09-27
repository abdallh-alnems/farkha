import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/functions/handing_data_controller.dart';
import '../../data/data_source/remote/tool_usage_data.dart';
// Note: ToolUsageData uses Crud class which automatically includes headers from headers.dart

class ToolUsageController extends GetxController {
  late StatusRequest statusRequest = StatusRequest.none;
  ToolUsageData toolUsageData = ToolUsageData(Get.find());

  /// Records tool usage by sending tool_id to the server
  /// Returns true if successful, false otherwise
  Future<bool> recordToolUsage(int toolId) async {
    statusRequest = StatusRequest.loading;
    update();

    try {
      final response = await toolUsageData.recordToolUsage(toolId);
      statusRequest = handlingData(response);

      if (response['status'] == "success") {
        statusRequest = StatusRequest.success;
        update();
        return true;
      } else {
        statusRequest = StatusRequest.failure;
        update();
        return false;
      }
    } catch (e) {
      statusRequest = StatusRequest.serverFailure;
      update();
      return false;
    }
  }

  /// Static method to record tool usage from any controller
  /// This eliminates the need to duplicate the recording logic in each controller
  static Future<void> recordToolUsageFromController(int toolId) async {
    try {
      final toolUsageController = Get.find<ToolUsageController>();
      await toolUsageController.recordToolUsage(toolId);
    } catch (e) {
      // Silently handle error - tool usage recording is not critical
      print('Failed to record tool usage for tool ID $toolId: $e');
    }
  }
}
