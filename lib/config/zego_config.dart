import 'package:flutter_dotenv/flutter_dotenv.dart';

class ZegoConfig {
  static int get appID {
    final appIdStr = dotenv.env['ZEGO_APP_ID'] ?? '1816273976';
    return int.tryParse(appIdStr) ?? 1816273976;
  }
  
  static String get appSign => 
      dotenv.env['ZEGO_APP_SIGN'] ?? 
      'b92a349b2eb7754dab0ec418da84933ca470c98e63c1dca6c900f8901cc47447';
}
