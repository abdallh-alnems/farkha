import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constant/headers.dart';
import '../package/internet_checker.dart';
import '../services/notification_service.dart';
import 'status_request.dart';

class Crud {
  Future<Either<StatusRequest, Map<String, dynamic>>> postData(String linkUrl, Map<String, dynamic> data) async {
    final Map<String, String> myHeaders = getMyHeaders();

    final bool isConnected = await InternetChecker.checkConnection();
    if (isConnected) {
      try {
        final http.Response response;

        if (data.isEmpty) {
          response = await http.get(Uri.parse(linkUrl), headers: myHeaders);
        } else {
          response = await http.post(
            Uri.parse(linkUrl),
            headers: myHeaders,
            body: jsonEncode(data),
          );
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
          return Right(responseBody);
        } else {
          debugPrint('Crud POST $linkUrl => ${response.statusCode}: ${response.body}');
          if (_isAccountGone(response)) {
            _triggerForceLogout();
          }
          return const Left(StatusRequest.serverFailure);
        }
      } catch (e) {
        debugPrint('Crud POST $linkUrl EXCEPTION: $e');
        return const Left(StatusRequest.serverFailure);
      }
    } else {
      return const Left(StatusRequest.offlineFailure);
    }
  }

  /// Detects backend responses that indicate the authenticated account no
  /// longer exists (deleted from DB or revoked in Firebase Auth) — see
  /// `core/Auth.php`: 401 for invalid/expired token, 404 "User not found".
  /// We only treat the response as account-gone when a Firebase user is
  /// currently signed in, to avoid logging out anonymous/unauthenticated calls.
  bool _isAccountGone(http.Response response) {
    if (FirebaseAuth.instance.currentUser == null) return false;
    if (response.statusCode == 401) return true;
    if (response.statusCode != 404) return false;
    try {
      final body = jsonDecode(response.body);
      if (body is! Map) return false;
      final message = body['message']?.toString().toLowerCase() ?? '';
      return message.contains('user not found');
    } catch (_) {
      return false;
    }
  }

  void _triggerForceLogout() {
    try {
      NotificationService.forceLogout();
    } catch (_) {}
  }
}
