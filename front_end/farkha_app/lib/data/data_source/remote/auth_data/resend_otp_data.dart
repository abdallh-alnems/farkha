import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/headers.dart';
import '../../../../core/constant/id/api.dart';
import '../../../../core/package/internet_checker.dart';

class ResendOtpData {
  Future<Either<StatusRequest, Map<String, dynamic>>> resendOtp({
    required String token,
    required String sessionToken,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      myHeaders['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse(Api.resendOtp),
        headers: myHeaders,
        body: jsonEncode({
          'token': token,
          'session_token': sessionToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        final Map<String, dynamic> errorBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(errorBody);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }
}
