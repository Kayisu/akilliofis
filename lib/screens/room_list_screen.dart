// lib/screens/room_list_screen.dart
import 'package:flutter/material.dart';
import '../widgets/room_list/room_card.dart';

class RoomListScreen extends StatelessWidget {
  const RoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: place_repo ile aktif odaları çek
    return Scaffold(
      appBar: AppBar(title: const Text('Odalar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: 6, // şimdilik mock
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            return RoomCard(
              onTap: () {
                // TODO: seçili odayı state'e yaz
                // ve Oda Detayları tabına geç
              },
            );
          },
        ),
      ),
    );
  }
}
