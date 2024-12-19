import '../../services/env.dart';

class ApiLinks {
  // ================================= server ==================================
  static final String _linkServerName = EnvService.linkServerName;

  // ================================= prices ==================================
  static String linkFarkhAbid = '$_linkServerName/view/farkh_abid.php';
  static String linkLastPrices = '$_linkServerName/view/last_prices.php';
  static String linkFeasibilityStudy =
      '$_linkServerName/view/feasibility_study.php';

  // =============================== suggestion ================================
  static String linkSuggestion = '$_linkServerName/suggestion.php';
}
