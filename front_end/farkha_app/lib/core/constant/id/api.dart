import '../../services/env.dart';

class Api {
  // ================================= server ==================================
  static final String _serverName = EnvService.linkServerName;

  // ================================ API MAIN =================================
  static final String _read = '$_serverName/app/read';
  static final String _livePrices = '$_read/live_prices';

  // ================================= prices ==================================
  static String mainTypes = '$_serverName/main.php';
  static String pricesByType = '$_read/prices_by_type.php';

  // ! feasibility study
  static String feasibilityStudy = '$_read/feasibility_study.php';

  // ! stream prices
  static String pricesStream = '$_livePrices/prices_stream.php';
  static String types = '$_livePrices/types.php';

  // =============================== suggestion ================================
  static String suggestion = '$_serverName/app/suggestion.php';

  // ============================ record tools usage ===========================
  static String recordToolsUsage =
      '$_serverName/analytics/record_tools_usage.php';
}
