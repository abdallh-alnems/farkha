import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/headers.dart';
import '../../../../core/constant/id/api.dart';
import '../../../../core/package/internet_checker.dart';

class CycleData {
  Future<Either<StatusRequest, Map<String, dynamic>>> createCycle({
    required String token,
    required String name,
    required int chickCount,
    required double space,
    String? breed,
    String? systemType,
    required String startDateRaw,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {
        'token': token,
        'name': name,
        'chick_count': chickCount,
        'space': space,
        'start_date_raw': startDateRaw,
      };

      if (breed != null && breed.isNotEmpty) {
        body['breed'] = breed;
      }

      if (systemType != null && systemType.isNotEmpty) {
        body['system_type'] = systemType;
      }

      final response = await http.post(
        Uri.parse(Api.createCycle),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> addCycleData({
    required String token,
    required int cycleId,
    required String label,
    required String value,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {
        'token': token,
        'cycle_id': cycleId,
        'label': label,
        'value': value,
      };

      final response = await http.post(
        Uri.parse(Api.addData),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> addCycleExpense({
    required String token,
    required int cycleId,
    required String label,
    required double value,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {
        'token': token,
        'cycle_id': cycleId,
        'label': label,
        'value': value,
      };

      final response = await http.post(
        Uri.parse(Api.addExpense),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> addCycleSale({
    required String token,
    required int cycleId,
    required int quantity,
    required double totalWeight,
    required double pricePerKg,
    required double totalPrice,
    String? saleDate,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = <String, dynamic>{
        'token': token,
        'cycle_id': cycleId,
        'quantity': quantity,
        'total_weight': totalWeight,
        'price_per_kg': pricePerKg,
        'total_price': totalPrice,
      };

      if (saleDate != null) {
        body['sale_date'] = saleDate;
      }

      final response = await http.post(
        Uri.parse(Api.addSale),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> deleteCycle({
    required String token,
    required int cycleId,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {'token': token, 'cycle_id': cycleId};

      final response = await http.post(
        Uri.parse(Api.deleteCycle),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getCycles({
    required String token,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {'token': token};

      final response = await http.post(
        Uri.parse(Api.getCycles),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getHistory({
    required String token,
    int page = 1,
    int limit = 5,
    String search = '',
    String dateFrom = '',
    String dateTo = '',
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = <String, dynamic>{
        'token': token,
        'page': page,
        'limit': limit,
      };

      if (search.isNotEmpty) {
        body['search'] = search;
      }
      if (dateFrom.isNotEmpty) {
        body['date_from'] = dateFrom;
      }
      if (dateTo.isNotEmpty) {
        body['date_to'] = dateTo;
      }

      final response = await http.post(
        Uri.parse(Api.getHistory),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getCycleDetails({
    required String token,
    required int cycleId,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {'token': token, 'cycle_id': cycleId};

      final response = await http.post(
        Uri.parse(Api.getCycleDetails),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> deleteCycleItem({
    required String token,
    required int cycleId,
    required String type, // "data" or "expense"
    required String deleteType, // "single" or "by_label"
    int? itemId, // required when deleteType = "single"
    String? label, // required when deleteType = "by_label"
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {
        'token': token,
        'cycle_id': cycleId,
        'type': type,
        'delete_type': deleteType,
      };

      if (deleteType == 'single' && itemId != null) {
        body['item_id'] = itemId;
      } else if (deleteType == 'by_label' && label != null) {
        body['label'] = label;
      }

      final response = await http.post(
        Uri.parse(Api.deleteCycleItem),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> endCycle({
    required String token,
    required int cycleId,
    String? endDate,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {
        'token': token,
        'cycle_id': cycleId,
        'status': 'finished',
      };

      if (endDate != null) {
        body['end_date'] = endDate;
      }

      final response = await http.post(
        Uri.parse(Api.updateStatus),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> addCycleNote({
    required String token,
    required int cycleId,
    required String content,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {'token': token, 'cycle_id': cycleId, 'content': content};

      final response = await http.post(
        Uri.parse(Api.addNote),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getCycleNotes({
    required String token,
    required int cycleId,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {'token': token, 'cycle_id': cycleId};

      final response = await http.post(
        Uri.parse(Api.getNotes),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> deleteCycleNote({
    required String token,
    required int cycleId,
    required int noteId,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {'token': token, 'cycle_id': cycleId, 'note_id': noteId};

      final response = await http.post(
        Uri.parse(Api.deleteNote),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> updateCycleNote({
    required String token,
    required int cycleId,
    required int noteId,
    required String content,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = await getMyHeadersWithAppCheck();

      final body = {
        'token': token,
        'cycle_id': cycleId,
        'note_id': noteId,
        'content': content,
      };

      final response = await http.post(
        Uri.parse(Api.updateNote),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

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
    required String action, // "accept" or "reject"
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
