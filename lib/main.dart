import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/app_router.dart';
import 'core/pb_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Web'de URL'deki # işaretini kaldırır
  usePathUrlStrategy();

  // PocketBase ve LocalStorage başlatılıyor
  await PbClient.init();

  runApp(const AkilliOfisApp());
}

class AkilliOfisApp extends StatelessWidget {
  const AkilliOfisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Akıllı Ofis',
      theme: ThemeData.dark(),
      routerConfig: AppRouter.router,
    );
  }
}
