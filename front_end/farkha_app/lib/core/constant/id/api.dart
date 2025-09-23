import '../../services/env.dart';

class Api {
  // ================================= server ==================================
  static final String _serverName = EnvService.linkServerName;

  // ================================ API MAIN =================================
  static final String _customListPrices = '$_serverName/read/live_prices';
  static final String _typesPrices = '$_serverName/read/types_prices';

  // ================================= prices ==================================
  static String mainTypes = '$_typesPrices/main.php';
  static String pricesByType = '$_typesPrices/prices_by_type.php';
  static String feasibilityStudy = '$_serverName/read/feasibility_study.php';

  // ! custom list prices
  static String pricesStream = '$_customListPrices/prices_stream.php';
  static String types = '$_customListPrices/types.php';

  // =============================== suggestion ================================
  static String suggestion = '$_serverName/suggestion.php';
}
