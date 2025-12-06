// lib/widgets/room_detail/room_sensor_stats.dart
import 'package:flutter/material.dart';
import '../../data/sensor_model.dart';

class RoomSensorStats extends StatelessWidget {
  final SensorData data; // Dışarıdan gelen veri

  const RoomSensorStats({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSensorCard(
                  value: "${data.humidity} %",
                  description: "Bağıl Nem Skoru: 0.5",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSensorCard(
                  value: "${data.temperature} °C",
                  description: "Sıcaklık Skoru: 0.8",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSensorCard(
                  value: "${data.co2} ppm",
                  description: "CO2 Skoru: 0.6",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSensorCard(
                  value: "${data.gas}",
                  description: "Ham Gaz Direnci Skoru: 0.4",
                  descriptionFontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Konfor Skoru: ${data.comfortScore}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String value,
    required String description,
    double descriptionFontSize = 12.0,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: descriptionFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
