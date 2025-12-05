import 'package:get/get.dart';

import '../../../core/class/crud.dart';
import '../../../core/constant/id/api.dart';
import '../../../core/services/test_mode_manager.dart';

class ToolUsageController extends GetxController {
  Crud crud = Get.find<Crud>();

  Future<bool> recordToolUsage(int toolId) async {
    if (!TestModeManager.canSendToolUsageData) {
      return false;
    }

    try {
      final response = await crud.postData(Api.toolsUsage, {
        'tool_id': toolId.toString(),
      });

      final result = response.fold(
        (failure) => <String, dynamic>{
          'status': 'error',
          'message': 'Failed to record tool usage',
        },
        (success) => success.cast<String, dynamic>(),
      );

      if (result['status'] == "success") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> recordToolUsageFromController(int toolId) async {
    if (!TestModeManager.canSendToolUsageData) {
      return;
    }

    ToolUsageController toolUsageController;
    if (Get.isRegistered<ToolUsageController>()) {
      toolUsageController = Get.find<ToolUsageController>();
    } else {
      toolUsageController = Get.put(ToolUsageController());
    }

    await toolUsageController.recordToolUsage(toolId);
  }
}
