import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/headers.dart';
import '../../../../core/constant/id/api.dart';
import '../../../../core/package/internet_checker.dart';

class CycleMemberData {
  Future<Either<StatusRequest, Map<String, dynamic>>> addMember({
    required String token,
    required int cycleId,
    required String phone,
    required String role,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) return const Left(StatusRequest.offlineFailure);
    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      final response = await http.post(
        Uri.parse(Api.addMember),
        headers: myHeaders,
        body: jsonEncode({
          'token': token,
          'cycle_id': cycleId,
          'phone': phone,
          'role': role,
        }),
      );
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 409) {
        return Right(body);
      }
      return const Left(StatusRequest.serverFailure);
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> leaveCycle({
    required String token,
    required int cycleId,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) return const Left(StatusRequest.offlineFailure);
    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      final response = await http.post(
        Uri.parse(Api.leaveCycle),
        headers: myHeaders,
        body: jsonEncode({'token': token, 'cycle_id': cycleId}),
      );
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        return Right(body);
      }
      return const Left(StatusRequest.serverFailure);
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> createInvitation({
    required String token,
    required int cycleId,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) return const Left(StatusRequest.offlineFailure);
    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      final response = await http.post(
        Uri.parse(Api.createInvitation),
        headers: myHeaders,
        body: jsonEncode({'token': token, 'cycle_id': cycleId}),
      );
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 409) {
        return Right(body);
      }
      return const Left(StatusRequest.serverFailure);
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> joinByCode({
    required String token,
    required String code,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) return const Left(StatusRequest.offlineFailure);
    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      final response = await http.post(
        Uri.parse(Api.joinByCode),
        headers: myHeaders,
        body: jsonEncode({'token': token, 'code': code}),
      );
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404 ||
          response.statusCode == 409) {
        return Right(body);
      }
      return const Left(StatusRequest.serverFailure);
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> searchUsers({
    required String token,
    required String searchTerm,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) return const Left(StatusRequest.offlineFailure);
    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      final response = await http.post(
        Uri.parse(Api.searchUsers),
        headers: myHeaders,
        body: jsonEncode({'token': token, 'search_term': searchTerm}),
      );
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(body);
      }
      return const Left(StatusRequest.serverFailure);
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getInvitations({
    required String token,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) return const Left(StatusRequest.offlineFailure);
    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      final response = await http.post(
        Uri.parse(Api.getInvitations),
        headers: myHeaders,
        body: jsonEncode({'token': token}),
      );
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(body);
      }
      return const Left(StatusRequest.serverFailure);
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> respondToInvitation({
    required String token,
    required int cycleId,
    required String action,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) return const Left(StatusRequest.offlineFailure);
    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      final response = await http.post(
        Uri.parse(Api.respondToInvitation),
        headers: myHeaders,
        body: jsonEncode({
          'token': token,
          'cycle_id': cycleId,
          'action': action,
        }),
      );
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(body);
      }
      return const Left(StatusRequest.serverFailure);
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> removeMember({
    required String token,
    required int cycleId,
    required int targetUserId,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) return const Left(StatusRequest.offlineFailure);
    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      final response = await http.post(
        Uri.parse(Api.removeMember),
        headers: myHeaders,
        body: jsonEncode({
          'token': token,
          'cycle_id': cycleId,
          'target_user_id': targetUserId,
        }),
      );
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        return Right(body);
      }
      return const Left(StatusRequest.serverFailure);
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> updateMemberRole({
    required String token,
    required int cycleId,
    required int targetUserId,
    required String newRole,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) return const Left(StatusRequest.offlineFailure);
    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();
      final response = await http.post(
        Uri.parse(Api.updateMemberRole),
        headers: myHeaders,
        body: jsonEncode({
          'token': token,
          'cycle_id': cycleId,
          'target_user_id': targetUserId,
          'new_role': newRole,
        }),
      );
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        return Right(body);
      }
      return const Left(StatusRequest.serverFailure);
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }
}
