import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/headers.dart';
import '../../../../core/constant/id/api.dart';
import '../../../../core/package/internet_checker.dart';

class UpdatePhoneData {
  Future<Either<StatusRequest, Map>> updatePhone({
    required String token,
    required String phone,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = getMyHeaders();
      myHeaders['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse(Api.updatePhone),
        headers: myHeaders,
        body: jsonEncode({'token': token, 'phone': phone}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map responseBody = jsonDecode(response.body);
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }
}
