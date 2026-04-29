import 'package:dartz/dartz.dart';

import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/id/api.dart';

class CycleFeedbackData {
  Crud crud;
  CycleFeedbackData(this.crud);

  Future<Either<StatusRequest, Map<String, dynamic>>> submit({
    required int rating,
    String? issue,
    String? suggestion,
    String? appVersion,
    String? platform,
  }) async {
    return await crud.postData(Api.submitCycleFeedback, {
      'rating': '$rating',
      if (issue != null) 'issue': issue,
      if (suggestion != null) 'suggestion': suggestion,
      if (appVersion != null) 'app_version': appVersion,
      if (platform != null) 'platform': platform,
    });
  }
}
