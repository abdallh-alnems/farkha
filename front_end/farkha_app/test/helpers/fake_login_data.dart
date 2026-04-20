import 'package:dartz/dartz.dart';
import 'package:farkha_app/core/class/status_request.dart';
import 'package:farkha_app/data/data_source/remote/auth_data/login_data.dart';

class FakeLoginData implements LoginData {
  Either<StatusRequest, Map<String, dynamic>>? loginResponse;
  Either<StatusRequest, Map<String, dynamic>>? signupResponse;

  @override
  Future<Either<StatusRequest, Map<String, dynamic>>> login(String token) async =>
      loginResponse ?? const Left(StatusRequest.serverFailure);
}
