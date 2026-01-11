import '../../services/env.dart';

class Api {
  // ================================= server ==================================
  static final String _serverName = EnvService.linkServerName;

  // ================================ API MAIN =================================
  static final String _read = '$_serverName/app/read';
  static final String _cardPrices = '$_read/card_prices';
  static final String _articles = '$_read/articles';
  static final String _auth = '$_serverName/app/auth';
  static final String _cycle = '$_serverName/app/cycles';

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

  // ================================== cycle ==================================
  static String broilerChicken = '$_cycle/broiler_chicken.php';
  static String createCycle = '$_cycle/create.php';
  static String deleteCycle = '$_cycle/delete.php';
  static String addData = '$_cycle/add_data.php';
  static String addExpense = '$_cycle/add_expense.php';
  static String getCycles = '$_cycle/get_cycles.php';
  static String getCycleDetails = '$_cycle/get_cycle_details.php';
  static String deleteCycleItem = '$_cycle/delete_cycle_item.php';
  static String updateStatus = '$_cycle/update_status.php';
}
