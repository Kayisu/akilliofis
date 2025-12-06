import 'package:flutter/material.dart';

class RoomOccupancyChart extends StatelessWidget {
  final String roomId; // Yeni parametre eklendi

  // onCreateReservation kaldırıldı, roomId eklendi
  const RoomOccupancyChart({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tarih Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.arrow_back_ios, size: 16),
              SizedBox(width: 10),
              Text(
                "24.11.2025 Pazartesi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
          const SizedBox(height: 20),

          // Lejant
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.black, "Doluluk (%)"),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.black, "Konfor Skoru"),
            ],
          ),
          const SizedBox(height: 20),

          // Grafik Alanı
          SizedBox(
            height: screenHeight * 0.4,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple.shade200, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar("09.00", 5, Colors.grey.shade400),
                  _buildBar("11.00", 10, Colors.grey.shade400),
                  _buildBar("13.00", 15, Colors.grey.shade400),
                  Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      _buildBar("15.00", 20, Colors.black),
                      Positioned(
                        top: -50,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            children: const [
                              Text(
                                "15.00",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Konfor Skoru: 18",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: height * 10,
          color: color,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}