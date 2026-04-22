import '../../../core/class/crud.dart';
import '../../../core/constant/id/api.dart';

class AppReviewData {
  Crud crud;
  AppReviewData(this.crud);

  Future<Object> upsert({
    required String token,
    required int rating,
    String? issue,
    String? suggestion,
    String? appVersion,
    String? platform,
  }) async {
    final response = await crud.postData(Api.upsertAppReview, {
      'token': token,
      'rating': '$rating',
      'issue': issue,
      'suggestion': suggestion,
      'app_version': appVersion,
      'platform': platform,
    });
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> fetchMine({required String token}) async {
    final response = await crud.postData(Api.getMyAppReview, {
      'token': token,
    });
    return response.fold((l) => l, (r) => r);
  }
}
