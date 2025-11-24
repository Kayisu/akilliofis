// lib/screens/room_detail_screen.dart
import 'package:flutter/material.dart';
import '../widgets/room_detail/room_detail_header.dart';
import '../widgets/room_detail/room_detail_pager.dart';
import 'reservation_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  const RoomDetailScreen({super.key});

  void _openReservation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReservationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: seçili oda yoksa "Oda seçilmedi" mesajı göster
    return Scaffold(
      appBar: AppBar(title: const Text('Oda Detayları')),
      body: Column(
        children: [
          const RoomDetailHeader(),
          Expanded(
            child: RoomDetailPager(
              onCreateReservation: () => _openReservation(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openReservation(context),
                child: const Text('Rezervasyon Oluştur'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
