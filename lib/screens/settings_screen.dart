// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final fullName = user?.getStringValue('fullName') ?? 'Bilinmiyor';
    final email = user?.getStringValue('email') ?? 'Bilinmiyor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Kullanıcı Bilgileri',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Ad Soyad'),
            subtitle: Text(fullName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await context.push('/profile-edit');
              // Profil ekranından dönüldüğünde ekranı yenile
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('E-posta'),
            subtitle: Text(email),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Hesap ve Uygulama',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: () {
              AuthService.instance.logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
