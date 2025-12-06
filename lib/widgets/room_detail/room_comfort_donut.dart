import 'package:flutter/material.dart';

class RoomComfortDonut extends StatelessWidget {
  final String roomId; // Yeni parametre

  // onCreateReservation kaldırıldı
  const RoomComfortDonut({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "Konfor Analizi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: Stack(
                  children: [
                    const SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 0.75,
                        strokeWidth: 50,
                        color: Colors.grey,
                        backgroundColor: Colors.black,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Konfor Skoru",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "%75",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.grey, "Konfor Skoru %75"),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.black, "Konforsuzluk %25"),
            ],
          ),
          // Buton buradan kaldırıldı, ana ekranda zaten var.
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}