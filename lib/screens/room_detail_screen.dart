// lib/screens/room_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- BU SATIRI EKLEYİN
import '../data/place_model.dart';
import '../widgets/room_detail/room_detail_pager.dart';
<<<<<<< HEAD

class RoomDetailScreen extends StatelessWidget {
  final String roomId = "1"; // Sabit bir oda ID'si varsayıyoruz

  const RoomDetailScreen({super.key});
=======
// import 'reservation_screen.dart'; // <-- Artık router ile gittiğimiz için buna gerek kalmayabilir ama kalsa da sorun olmaz.

class RoomDetailScreen extends StatelessWidget {
  final PlaceModel place;

  const RoomDetailScreen({super.key, required this.place});

  void _openReservation(BuildContext context) {
    context.push('/reservation/create', extra: place);
  }
>>>>>>> 1e08affc9a731389a20d32ccb1e861428c6a75ff

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
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
=======
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
>>>>>>> 1e08affc9a731389a20d32ccb1e861428c6a75ff
        ],
      ),
    );
  }
}