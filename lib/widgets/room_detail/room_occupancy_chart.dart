// lib/widgets/room_detail/room_occupancy_chart.dart
import 'package:flutter/material.dart';

class RoomOccupancyChart extends StatelessWidget {
  final VoidCallback onCreateReservation;

  const RoomOccupancyChart({super.key, required this.onCreateReservation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Center(child: Text('Doluluk / Konfor Bar Chart (TODO)')),
        ),
      ],
    );
  }
}
