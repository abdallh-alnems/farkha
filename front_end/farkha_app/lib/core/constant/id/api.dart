import '../../services/env.dart';

class Api {
  // ================================= server ==================================
  static final String _serverName = EnvService.linkServerName;

  // ================================ API MAIN =================================
  static final String _customListPrices =
      '$_serverName/read/custom_list_prices';
  static final String _lastPrices = '$_serverName/read/last_prices';


  // ================================= prices ==================================
  static String mainTypes = '$_serverName/read/main.php';
  static String typesPrices = '$_lastPrices/types_prices.php';
  static String feedPrices = '$_lastPrices/feed_prices.php';
  static String feasibilityStudy = '$_serverName/read/feasibility_study.php';

  // ! custom list prices
  static String pricesStream = '$_customListPrices/prices_stream.php';
  static String types = '$_customListPrices/types.php';

  // =============================== suggestion ================================
  static String suggestion = '$_serverName/suggestion.php';

}
