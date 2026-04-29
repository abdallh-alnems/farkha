import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/headers.dart';
import '../../../../core/constant/id/api.dart';
import '../../../../core/package/internet_checker.dart';

class UpdatePhoneData {
  Future<Either<StatusRequest, Map<String, dynamic>>> updatePhone({
    required String token,
    String? phone,
    String? verifiedToken,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      myHeaders['Content-Type'] = 'application/json';

      final Map<String, dynamic> body = {'token': token};
      if (verifiedToken != null) {
        body['verified_token'] = verifiedToken;
      } else if (phone != null) {
        body['phone'] = phone;
      } else {
        return const Left(StatusRequest.failure);
      }

      final response = await http.post(
        Uri.parse(Api.updatePhone),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        return Right(errorBody);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }
}
