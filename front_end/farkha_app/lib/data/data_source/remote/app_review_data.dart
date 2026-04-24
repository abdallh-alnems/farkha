import 'package:dartz/dartz.dart';

import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/id/api.dart';

class AppReviewData {
  Crud crud;
  AppReviewData(this.crud);

  Future<Either<StatusRequest, Map<String, dynamic>>> submit({
    int rating = 0,
    String? issue,
    String? suggestion,
    String? appVersion,
    String? platform,
  }) async {
    final data = <String, String>{};
    if (rating > 0) data['rating'] = '$rating';
    if (issue != null) data['issue'] = issue;
    if (suggestion != null) data['suggestion'] = suggestion;
    if (appVersion != null) data['app_version'] = appVersion;
    if (platform != null) data['platform'] = platform;
    return await crud.postData(Api.upsertAppReview, data);
  }
}
