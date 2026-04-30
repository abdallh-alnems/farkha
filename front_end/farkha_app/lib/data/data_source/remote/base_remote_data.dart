import '../../../core/class/crud.dart';

abstract class BaseRemoteData {
  final Crud crud;
  BaseRemoteData(this.crud);

  Future<dynamic> request({
    required String url,
    Map<String, dynamic>? data,
  }) async {
    final response = await crud.postData(url, data ?? {});
    return response.fold((l) => l, (r) => r);
  }
}
