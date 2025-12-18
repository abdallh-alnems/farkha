import '../../services/env.dart';

class Api {
  // ================================= server ==================================
  static final String _serverName = EnvService.linkServerName;

  // ================================ API MAIN =================================
  static final String _read = '$_serverName/app/read';
  static final String _cardPrices = '$_read/card_prices';
  static final String _articles = '$_read/articles';
  static final String _auth = '$_serverName/app/auth';

  // ================================= prices ==================================
  static String mainTypes = '$_read/main_types.php';
  static String pricesByType = '$_read/prices_by_type.php';

  // ! feasibility study
  static String feasibilityStudy = '$_read/feasibility_study.php';

  // ! card prices
  static String pricesCard = '$_cardPrices/card_prices.php';
  static String types = '$_cardPrices/types.php';

  // =============================== suggestion ================================
  static String suggestion = '$_read/suggestions.php';

  // ============================ record tools usage ===========================
  static String toolsUsage = '$_serverName/analytics/record_tools_usage.php';

  // ================================ articles =================================
  static String articleDetail = '$_articles/article_detail.php';
  static String articlesList = '$_articles/articles_list.php';

  // ============================== authentication =============================
  static String login = '$_auth/login.php';
  static String updateName = '$_auth/update_name.php';
  static String updatePhone = '$_auth/update_phone.php';
  static String deleteAccount = '$_auth/delete_account.php';
}
