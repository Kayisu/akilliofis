import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

/// NOT: Bu widget daha önce RoomDetailHeader idi.
/// Ana sayfaya taşındığı için adı HomeHeader olarak güncellendi.
/// Kullanıcı karşılama ve profil resmi burada gösteriliyor.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final rawName = user?.getStringValue('fullName');
    
    String firstName = 'Kullanıcı';
    if (rawName != null && rawName.trim().isNotEmpty) {
      firstName = rawName.trim().split(' ').first;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hoşgeldin,',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                firstName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 24,
            child: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
