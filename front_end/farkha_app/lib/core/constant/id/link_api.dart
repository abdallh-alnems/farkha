import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiLinks {
static  String linkServerName = dotenv.get("API_HOST");


  static  String linkViewLastPriceFarkhAbid =
      '$linkServerName/view/last_price/farkh_abid.php';
}
