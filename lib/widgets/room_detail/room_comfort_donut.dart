// lib/widgets/room_detail/room_comfort_donut.dart
import 'package:flutter/material.dart';

class RoomComfortDonut extends StatelessWidget {
  final VoidCallback onCreateReservation;

  const RoomComfortDonut({super.key, required this.onCreateReservation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Center(child: Text('Konfor Donut (TODO)')),
        ),
        ElevatedButton(
          onPressed: onCreateReservation,
          child: const Text('Rezervasyon Oluştur'),
        ),
      ],
    );
  }
}
