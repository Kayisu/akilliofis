// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // İleride: auth servisinden gerçek kullanıcı bilgisi çekebiliriz.
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
            subtitle: const Text('Bahar Gökçül'), // TODO: auth’tan doldur
            onTap: () {
              // TODO: profil düzenleme ekranı
            },
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('E-posta'),
            subtitle: const Text('bahar@example.com'), // TODO: auth’tan doldur
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
          SwitchListTile(
            title: const Text('E-posta bildirimleri'),
            value: true,
            onChanged: (v) {
              // TODO: kullanıcı tercihleri kaydedilecek
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: () {
              // TODO: authService.logout() + login ekranına yönlendir
            },
          ),
        ],
      ),
    );
  }
}
