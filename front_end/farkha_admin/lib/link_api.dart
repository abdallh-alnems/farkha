import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiLinks {
  static  String linkServerName = dotenv.get("API_HOST");

  static  String add =
      '$linkServerName/add.php';
}
