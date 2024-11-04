import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Map<String, String> getMyHeaders() {
  String securityKey = dotenv.get("SECURITY_KEY");
  String securityUser = dotenv.get("SECURITY_USER");
  String basicAuth = 'Basic ${base64Encode(utf8.encode('$securityUser:$securityKey'))}';
  return {'authorization': basicAuth};
}