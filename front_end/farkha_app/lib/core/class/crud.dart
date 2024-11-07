import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../constant/headers.dart';
import 'status_request.dart';

class Crud {
  Future<Either<StatusRequest, Map>> postData(String linkUrl, Map data) async {
    Map<String, String> myheaders = getMyHeaders();

    var response =
        await http.post(Uri.parse(linkUrl), headers: myheaders, body: data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map responseBody = jsonDecode(response.body);

      return Right(responseBody);
    } else {
      return const Left(StatusRequest.serverFailure);
    }
  }
}
