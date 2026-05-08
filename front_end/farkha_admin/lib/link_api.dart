import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ApiLinks {
  static String linkServerName = dotenv.get("API_HOST");

  // Prices
  static String addPrices = '$linkServerName/admin/prices/add.php';
  static String updatePrices = '$linkServerName/admin/prices/update.php';
  static String deletePrices = '$linkServerName/admin/prices/delete.php';
  static String getLastPrices = '$linkServerName/admin/prices/today.php';

  // Articles
  static String addArticles = '$linkServerName/admin/articles/add.php';
  static String updateArticles = '$linkServerName/admin/articles/update.php';

  // Read endpoints (shared with app)
  static String mainTypes = '$linkServerName/app/prices/main_types.php';
  static String articleDetail = '$linkServerName/app/articles/detail.php';
  static String articlesList = '$linkServerName/app/articles/list.php';

  // Analytics
  static String toolsAnalytics = '$linkServerName/analytics/tools_analytics.php';

  // Cache
  static String deleteCash = '$linkServerName/cache_system/clear_cache.php';
}

Map<String, String> getMyHeaders() {
  String securityUser = dotenv.get("SECURITY_USER");
  String securityKey = dotenv.get("SECURITY_KEY");
  String basicAuth =
      'Basic ${base64Encode(utf8.encode('$securityUser:$securityKey'))}';
  return {'authorization': basicAuth, 'Content-Type': 'application/json'};
}
