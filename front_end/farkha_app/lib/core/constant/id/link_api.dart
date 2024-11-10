import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiLinks {
  static final String _linkServerName = dotenv.get("API_HOST");

  static String linkFarkhAbid = '$_linkServerName/view/farkh_abid.php';
  static String linkSuggestion = '$_linkServerName/suggestion.php';
}
