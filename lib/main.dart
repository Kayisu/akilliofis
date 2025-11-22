import 'package:flutter/material.dart';
import 'features/auth/presentation/login_screen.dart';

void main() {
  runApp(const AkilliOfisApp());
}

class AkilliOfisApp extends StatelessWidget {
  const AkilliOfisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akıllı Ofis',
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}
