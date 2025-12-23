//room_card.dart
import 'package:flutter/material.dart';
import '../../data/place_model.dart';

class RoomCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback? onTap;

  const RoomCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: place.isActive ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: place.isActive ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                place.isActive ? 'Durum: Aktif' : 'Durum: Pasif',
                style: TextStyle(
                  color: place.isActive ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 12,
                ),
              ),
              Text(
                'Kapasite: ${place.capacity}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
