import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiLinks {
  static String linkServerName = dotenv.get("API_HOST");

  static String linkFarkhAbid = '$linkServerName/view/farkh_abid.php';
}
