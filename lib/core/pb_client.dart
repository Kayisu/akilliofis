import 'package:pocketbase/pocketbase.dart';
import 'app_config.dart';

class PbClient {
  PbClient._internal();

  static final PbClient _instance = PbClient._internal();
  static PbClient get I => _instance;

  late final PocketBase client = PocketBase(AppConfig.pocketBaseUrl);
}

class PBClient {
  static final List<Map<String, dynamic>> roomData = [
    {
      "roomId": "1",
      "temperature": 26.5,
      "humidity": 43,
      "co2": 774,
      "gas": 75,
      "comfortScore": 0.6,
    },
    {
      "roomId": "2",
      "temperature": 24.0,
      "humidity": 50,
      "co2": 800,
      "gas": 70,
      "comfortScore": 0.7,
    },
  ];
}
