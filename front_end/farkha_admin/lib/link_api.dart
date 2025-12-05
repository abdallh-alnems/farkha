import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ApiLinks {
  static String linkServerName = dotenv.get("API_HOST");

  static String addPrices = '$linkServerName/admin/create/add_prices.php';
  static String updatePrices = '$linkServerName/admin/update/update_prices.php';
  static String deletePrices = '$linkServerName/admin/delete/delete_prices.php';

  static String mainTypes = '$linkServerName/app/read/main_types.php';
  static String getLastPrices = '$linkServerName/admin/read/today_prices.php';
  static String toolsAnalytics =
      '$linkServerName/analytics/tools_analytics.php';
  static String articleDetail =
      '$linkServerName/app/read/articles/article_detail.php';
  static String articlesList =
      '$linkServerName/app/read/articles/articles_list.php';
  static String updateArticles =
      '$linkServerName/admin/update/update_articles.php';
  static String addArticles = '$linkServerName/admin/create/add_articles.php';

  static String deleteCash = '$linkServerName/cache_system/clear_cache.php';
  static String suggestions = '$linkServerName/admin/read/list_suggestions.php';
}

Map<String, String> getMyHeaders() {
  String securityUser = dotenv.get("SECURITY_USER");
  String securityKey = dotenv.get("SECURITY_KEY");
  String basicAuth =
      'Basic ${base64Encode(utf8.encode('$securityUser:$securityKey'))}';
  return {'authorization': basicAuth};
}
