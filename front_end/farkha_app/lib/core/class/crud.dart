import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../constant/headers.dart';
import '../functions/check_internet.dart';
import 'status_request.dart';

class Crud {
  Future<Either<StatusRequest, Map>> postData(String linkUrl, Map data) async {
    Map<String, String> myHeaders = getMyHeaders();

    bool isConnected = await InternetController.checkInternet();
    if (isConnected) {
      try {
        var response =
            await http.post(Uri.parse(linkUrl), headers: myHeaders, body: data);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responseBody = jsonDecode(response.body);
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
