import 'dart:convert';

import '../services/env.dart';

Map<String, String> getMyHeaders() {
  final String securityUser = EnvService.securityUser;
  final String securityKey = EnvService.securityKey;
  final String basicAuth =
      'Basic ${base64Encode(utf8.encode('$securityUser:$securityKey'))}';
  return {'authorization': basicAuth};
}
