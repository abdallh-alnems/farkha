import 'package:dartz/dartz.dart';

import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/id/api.dart';

class AppReviewData {
  Crud crud;
  AppReviewData(this.crud);

  Future<Either<StatusRequest, Map<String, dynamic>>> upsert({
    required String token,
    required int rating,
    String? issue,
    String? suggestion,
    String? appVersion,
    String? platform,
  }) async {
    return await crud.postData(Api.upsertAppReview, {
      'token': token,
      'rating': '$rating',
      'issue': issue,
      'suggestion': suggestion,
      'app_version': appVersion,
      'platform': platform,
    });
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> fetchMine({
    required String token,
  }) async {
    return await crud.postData(Api.getMyAppReview, {
      'token': token,
    });
  }
}
