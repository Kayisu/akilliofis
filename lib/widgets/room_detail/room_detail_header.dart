// lib/widgets/room_detail/room_detail_header.dart
import 'package:flutter/material.dart';

class RoomDetailHeader extends StatelessWidget {
  const RoomDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: auth + seçili oda bilgisi
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Hoşgeldin,\nBahar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          CircleAvatar(radius: 22),
        ],
      ),
    );
  }
}
