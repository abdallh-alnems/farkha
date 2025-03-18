import '../../services/env.dart';

class ApiLinks {
  // ================================= server ==================================
  static final String _serverName = EnvService.linkServerName;

  // ================================= prices ==================================
  static String farkhAbid = '$_serverName/read/farkh_abid.php';
  static String mainTypes = '$_serverName/read/main.php';
  static String lastPrices = '$_serverName/read/last_prices.php';
  static String feasibilityStudy = '$_serverName/read/feasibility_study.php';

  // =============================== suggestion ================================
  static String suggestion = '$_serverName/suggestion.php';
}
