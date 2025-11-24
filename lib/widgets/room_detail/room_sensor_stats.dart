// lib/widgets/room_detail/room_sensor_stats.dart
import 'package:flutter/material.dart';

class RoomSensorStats extends StatelessWidget {
  final VoidCallback onCreateReservation;

  const RoomSensorStats({super.key, required this.onCreateReservation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Center(child: Text('Sensör Kartları + Konfor Skoru (TODO)')),
        ),
        ElevatedButton(
          onPressed: onCreateReservation,
          child: const Text('Rezervasyon Oluştur'),
        ),
      ],
    );
  }
}
