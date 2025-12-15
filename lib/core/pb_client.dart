import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';

class PbClient {
  static PbClient? _instance;
  static PbClient get I => _instance!;

  final PocketBase client;

  PbClient._(this.client);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Oturum zaman aşımı kontrolü (24 saat)
    final lastLoginStr = prefs.getString('last_login_timestamp');
    if (lastLoginStr != null) {
      final lastLogin = DateTime.parse(lastLoginStr);
      final difference = DateTime.now().difference(lastLogin);
      
      if (difference.inHours >= 24) {
        // Süre dolduysa oturum verilerini temizle
        await prefs.remove('pb_auth');
        await prefs.remove('last_login_timestamp');
      }
    }

    // 2. Kimlik doğrulama deposu yapılandırması
    final store = AsyncAuthStore(
      save: (String data) async {
        await prefs.setString('pb_auth', data);
        // Her giriş veya yenileme işleminde zaman damgasını güncelle
        await prefs.setString('last_login_timestamp', DateTime.now().toIso8601String());
      },
      initial: prefs.getString('pb_auth'),
      clear: () async {
        await prefs.remove('pb_auth');
        await prefs.remove('last_login_timestamp');
      },
    );

    final pb = PocketBase(AppConfig.pocketBaseUrl, authStore: store);

    _instance = PbClient._(pb);
  }
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
