import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../constant/headers.dart';
import '../package/internet_checker.dart';
import 'status_request.dart';

class Crud {
  Future<Either<StatusRequest, Map<String, dynamic>>> postData(String linkUrl, Map<String, dynamic> data) async {
    final Map<String, String> myHeaders = getMyHeaders();

    final bool isConnected = await InternetChecker.checkConnection();
    if (isConnected) {
      try {
        final http.Response response;

        // Use GET if data is empty, otherwise use POST
        if (data.isEmpty) {
          response = await http.get(Uri.parse(linkUrl), headers: myHeaders);
        } else {
          response = await http.post(
            Uri.parse(linkUrl),
            headers: myHeaders,
            body: data,
          );
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
          return Right(responseBody);
        } else {
          return const Left(StatusRequest.serverFailure);
        }
      } catch (e) {
        return const Left(StatusRequest.serverFailure);
      }
    } else {
      return const Left(StatusRequest.offlineFailure);
    }
  }
}
