import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static final String linkServerName = dotenv.get('API_HOST');
  static final String securityUser = dotenv.get('SECURITY_USER');
  static final String securityKey = dotenv.get('SECURITY_KEY');
  static final String weatherApi = dotenv.get('WEATHER_API');
}
