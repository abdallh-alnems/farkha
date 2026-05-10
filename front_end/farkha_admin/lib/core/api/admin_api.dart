import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminApiException implements Exception {
  final String message;
  final int? statusCode;
  AdminApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class AdminApi {
  static String get _base => dotenv.get('API_HOST');

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_token');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', token);
  }

  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    await prefs.remove('admin_info');
  }

  static Future<void> saveAdminInfo(Map<String, dynamic> admin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_info', jsonEncode(admin));
  }

  static Future<Map<String, dynamic>?> getAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('admin_info');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final headers = await _headers();
    final res = await http.post(
      Uri.parse('$_base$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final headers = await _headers();
    final res = await http.get(
      Uri.parse('$_base$path'),
      headers: headers,
    );
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> _handleResponse(http.Response res) async {
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 401) {
      await _clearToken();
      Get.offAllNamed('/login');
      throw AdminApiException('انتهت الجلسة، سجل دخول مجدداً', 401);
    }

    if (res.statusCode == 403) {
      throw AdminApiException(data['message'] ?? 'ليس لديك صلاحية', 403);
    }

    if (res.statusCode == 429) {
      throw AdminApiException('طلبات كثيرة، حاول لاحقاً', 429);
    }

    if (data['status'] == 'success') {
      return data;
    }

    throw AdminApiException(
      data['message'] ?? 'حدث خطأ',
      res.statusCode,
    );
  }

  static Future<void> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_base/admin/auth/login.php'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (res.statusCode == 429) {
      throw AdminApiException('طلبات كثيرة، حاول لاحقاً', 429);
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (data['status'] == 'success' && data['data'] != null) {
      final token = data['data']['token'] as String;
      await _saveToken(token);
      await saveAdminInfo(data['data']['admin'] as Map<String, dynamic>);
      return;
    }

    throw AdminApiException(
      data['message'] ?? 'بيانات خاطئة',
      res.statusCode,
    );
  }

  static Future<void> logout() async {
    try {
      await post('/admin/auth/logout.php');
    } catch (_) {}
    await _clearToken();
  }
}
