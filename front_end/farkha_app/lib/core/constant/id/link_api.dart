import '../../services/env.dart';

class ApiLinks {
  // ================================= server ==================================
  static final String _serverName = EnvService.linkServerName;

  // ================================= prices ==================================
  static String mainTypes = '$_serverName/read/main.php';
  static String lastPrices = '$_serverName/read/last_prices.php';
  static String feasibilityStudy = '$_serverName/read/feasibility_study.php';

  //! custom list prices
  static String pricesStream =
      '$_serverName/read/custom_list_prices/prices_stream.php';
  static String types = '$_serverName/read/custom_list_prices/types.php';

  

  // =============================== suggestion ================================
  static String suggestion = '$_serverName/suggestion.php';
}
