// lib/widgets/room_list/room_card.dart
import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {
  final VoidCallback? onTap;

  const RoomCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Oda 1', style: TextStyle(color: Colors.white)),
            Text('Durum: Aktif', style: TextStyle(color: Colors.white70)),
            Text('Kapasite: 5', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
