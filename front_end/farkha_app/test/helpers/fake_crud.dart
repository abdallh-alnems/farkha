import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/crud.dart';
import 'package:farkha_app/core/class/status_request.dart';

class FakeCrud extends Crud {
  final Map<String, Either<StatusRequest, Map<String, dynamic>>> _scripts = {};
  final List<({String url, Map<String, dynamic> data})> calls = [];

  void whenPost(String url, Either<StatusRequest, Map<String, dynamic>> response) {
    _scripts[url] = response;
  }

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> postData(
    String linkUrl,
    Map<String, dynamic> data,
  ) async {
    calls.add((url: linkUrl, data: data));
    return _scripts[linkUrl] ?? const Left(StatusRequest.serverFailure);
  }
}
