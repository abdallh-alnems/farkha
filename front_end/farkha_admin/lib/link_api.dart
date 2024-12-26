import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ApiLinks {
  static String linkServerName = dotenv.get("API_HOST");

  static String add = '$linkServerName/add.php';

  static String main = '$linkServerName/read/main.php';
  static String getLastPrices = '$linkServerName/read/last_prices.php';
}

Map<String, String> getMyHeaders() {
  String securityUser = dotenv.get("SECURITY_USER");
  String securityKey = dotenv.get("SECURITY_KEY");
  String basicAuth =
      'Basic ${base64Encode(utf8.encode('$securityUser:$securityKey'))}';
  return {'authorization': basicAuth};
}
