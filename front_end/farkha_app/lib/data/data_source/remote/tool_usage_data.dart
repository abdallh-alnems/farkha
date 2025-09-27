import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/api.dart';
// Note: Crud class automatically includes headers from headers.dart for authentication

class ToolUsageData {
  final Crud crud;

  ToolUsageData(this.crud);

  Future<Map<String, dynamic>> recordToolUsage(int toolId) async {
    final response = await crud.postData(Api.recordToolsUsage, {
      'tool_id': toolId.toString(),
    });

    return response.fold(
      (failure) => <String, dynamic>{
        'status': 'error',
        'message': 'Failed to record tool usage',
      },
      (success) => success.cast<String, dynamic>(),
    );
  }
}
