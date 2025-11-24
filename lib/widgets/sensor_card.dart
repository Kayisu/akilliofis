import 'package:flutter/material.dart';
import 'circular_gauge.dart';

class SensorModel {
  final String id;
  final String name;
  final String type; // "temperature" | "humidity" | "co2" | "pir"
  final double value;
  final String unit;
  final DateTime? updatedAt;

  SensorModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.unit = '',
    this.updatedAt,
  });
}

class SensorCard extends StatelessWidget {
  final SensorModel sensor;
  const SensorCard({super.key, required this.sensor});

  Color _typeColor() {
    switch (sensor.type) {
      case 'temperature':
        return const Color(0xFFFF7A7A);
      case 'humidity':
        return const Color(0xFF60A5FA);
      case 'co2':
        return const Color(0xFFF59E0B);
      case 'pir':
        return const Color(0xFFA78BFA);
      default:
        return Colors.grey;
    }
  }

  double _maxForType() {
    switch (sensor.type) {
      case 'temperature':
        return 50;
      case 'co2':
        return 2000;
      case 'humidity':
        return 100;
      default:
        return 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF180623), Color(0xFF0E0616)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            // withOpacity deprecated -> withAlpha kullanıldı
            color: color.withAlpha((0.12 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sensor.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  sensor.type.toUpperCase(),
                  style: const TextStyle(color: Colors.black, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircularGauge(
                value: sensor.value,
                min: 0,
                max: _maxForType(),
                unit: sensor.unit,
                size: 120,
                startColor: color,
                endColor: Colors.purple,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${sensor.value}${sensor.unit}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Güncel: ${sensor.updatedAt != null ? TimeOfDay.fromDateTime(sensor.updatedAt!).format(context) : '—'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
