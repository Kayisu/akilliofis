// lib/screens/room_detail_screen.dart
import 'package:flutter/material.dart';
import '../data/place_model.dart';
import '../widgets/room_detail/room_detail_pager.dart';
import 'reservation_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  final PlaceModel place;

  const RoomDetailScreen({super.key, required this.place});

  void _openReservation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReservationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: Column(
        children: [
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
