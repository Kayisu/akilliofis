//main.dart
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/app_router.dart';
import 'core/pb_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await PbClient.init();

  runApp(const AkilliOfisApp());
}
class AkilliOfisApp extends StatelessWidget {
  const AkilliOfisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Akıllı Ofis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF7E57C2),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7E57C2),
          secondary: const Color(0xFFB39DDB),
          surface: Colors.grey.shade900,
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}