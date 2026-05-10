import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiLinks {
  static String linkServerName = dotenv.get("API_HOST");
  static String addPrices = '$linkServerName/admin/prices/add.php';
  static String updatePrices = '$linkServerName/admin/prices/update.php';
  static String deletePrices = '$linkServerName/admin/prices/delete.php';
  static String getLastPrices = '$linkServerName/admin/prices/today.php';
  static String addArticles = '$linkServerName/admin/articles/add.php';
  static String updateArticles = '$linkServerName/admin/articles/update.php';
  static String mainTypes = '$linkServerName/app/prices/main_types.php';
  static String articleDetail = '$linkServerName/app/articles/detail.php';
  static String articlesList = '$linkServerName/app/articles/list.php';
  static String toolsAnalytics = '$linkServerName/analytics/tools_analytics.php';
  static String deleteCash = '$linkServerName/admin/cache/clear.php';
}

Map<String, String> getMyHeaders() {
  return {'Content-Type': 'application/json'};
}

Map<String, String> getAuthHeaders(String token) {
  return {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
}

Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('admin_token');
}

Future<Map<String, String>> getAuthHeadersAsync() async {
  final token = await _getToken();
  return {
    'Authorization': 'Bearer ${token ?? ''}',
    'Content-Type': 'application/json',
  };
}
