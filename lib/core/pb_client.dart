import 'package:pocketbase/pocketbase.dart';
import 'app_config.dart';

class PbClient {
  PbClient._internal();

  static final PbClient _instance = PbClient._internal();
  static PbClient get I => _instance;

  late final PocketBase client = PocketBase(AppConfig.pocketBaseUrl);
}
