import 'dart:convert';
import 'package:firebase_app_check/firebase_app_check.dart';

import '../services/env.dart';

Map<String, String> getMyHeaders() {
  final String securityUser = EnvService.securityUser;
  final String securityKey = EnvService.securityKey;
  final String basicAuth =
      'Basic ${base64Encode(utf8.encode('$securityUser:$securityKey'))}';
  return {'authorization': basicAuth, 'Content-Type': 'application/json'};
}

Future<Map<String, String>> getMyHeadersWithAppCheck() async {
  final headers = getMyHeaders();

  try {
    final appCheckToken = await FirebaseAppCheck.instance.getToken();
    if (appCheckToken != null) {
      headers['X-Firebase-AppCheck'] = appCheckToken;
    }
  } catch (_) {}

  return headers;
}
