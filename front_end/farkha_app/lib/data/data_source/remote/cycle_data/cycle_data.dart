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
    required String startDateRaw,
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = getMyHeaders();
      myHeaders['Content-Type'] = 'application/json';

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

      final response = await http.post(
        Uri.parse(Api.createCycle),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
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
      final Map<String, String> myHeaders = getMyHeaders();
      myHeaders['Content-Type'] = 'application/json';

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
        final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
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
      final Map<String, String> myHeaders = getMyHeaders();
      myHeaders['Content-Type'] = 'application/json';

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
        final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
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
      final Map<String, String> myHeaders = getMyHeaders();
      myHeaders['Content-Type'] = 'application/json';

      final body = {'token': token, 'cycle_id': cycleId};

      final response = await http.post(
        Uri.parse(Api.deleteCycle),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getCycles({required String token}) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = getMyHeaders();
      myHeaders['Content-Type'] = 'application/json';

      final body = {'token': token};

      final response = await http.post(
        Uri.parse(Api.getCycles),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
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
      final Map<String, String> myHeaders = getMyHeaders();
      myHeaders['Content-Type'] = 'application/json';

      final body = {'token': token, 'cycle_id': cycleId};

      final response = await http.post(
        Uri.parse(Api.getCycleDetails),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
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
      final Map<String, String> myHeaders = getMyHeaders();
      myHeaders['Content-Type'] = 'application/json';

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
        final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
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
  }) async {
    final bool isConnected = await InternetChecker.checkConnection();
    if (!isConnected) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final Map<String, String> myHeaders = getMyHeaders();
      myHeaders['Content-Type'] = 'application/json';

      final body = {'token': token, 'cycle_id': cycleId, 'status': 'finished'};

      final response = await http.post(
        Uri.parse(Api.updateStatus),
        headers: myHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        return Right(responseBody);
      } else {
        return const Left(StatusRequest.serverFailure);
      }
    } catch (e) {
      return const Left(StatusRequest.serverFailure);
    }
  }
}
