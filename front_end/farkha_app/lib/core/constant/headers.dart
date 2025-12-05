import 'dart:convert';

import '../services/env.dart';

Map<String, String> getMyHeaders() {
  String securityUser = EnvService.securityUser;
  String securityKey = EnvService.securityKey;
  String basicAuth =
      'Basic ${base64Encode(utf8.encode('$securityUser:$securityKey'))}';
  return {'authorization': basicAuth};
}
