// lib/screens/room_detail_screen.dart
import 'package:flutter/material.dart';
import '../widgets/room_detail/room_detail_header.dart';
import '../widgets/room_detail/room_detail_pager.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomId = "1"; // Sabit bir oda ID'si varsayıyoruz

  const RoomDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Oda Detayları',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Üst Başlık
          const RoomDetailHeader(),

          // Kaydırmalı Grafikler
          Expanded(child: RoomDetailPager(roomId: roomId)),
        ],
      ),
    );
  }
}
