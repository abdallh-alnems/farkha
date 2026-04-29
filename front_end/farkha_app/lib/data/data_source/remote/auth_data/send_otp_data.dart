import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/headers.dart';
import '../../../../core/constant/id/api.dart';
import '../../../../core/package/internet_checker.dart';

class SendOtpData {
  Future<Either<StatusRequest, Map<String, dynamic>>> sendOtp({
    required String token,
    required String phone,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      myHeaders['Content-Type'] = 'application/json';

      dev.log('[send_otp] POST ${Api.sendOtp} phone=$phone token_len=${token.length}', name: 'OTP');

      final response = await http.post(
        Uri.parse(Api.sendOtp),
        headers: myHeaders,
        body: jsonEncode({'token': token, 'phone': phone}),
      );

      dev.log('[send_otp] status=${response.statusCode} body=${response.body}', name: 'OTP');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      }

      try {
        final Map<String, dynamic> errorBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(errorBody);
      } catch (e) {
        dev.log('[send_otp] JSON decode failed: $e', name: 'OTP');
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e, s) {
      dev.log('[send_otp] HTTP threw: $e\n$s', name: 'OTP');
      return const Left(StatusRequest.serverFailure);
    }
  }
}
