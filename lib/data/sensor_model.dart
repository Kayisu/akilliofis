//lib/data/sensor_model.dart
import 'package:pocketbase/pocketbase.dart';

class SensorData {
  final double temperature;
  final double humidity;
  final int co2;
  final int gas; // VOC Index
  final double comfortScore;
  final bool isOccupied; // Hareket algılandı mı?
  final DateTime? recordedAt;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.gas,
    required this.comfortScore,
    this.isOccupied = false, // Varsayılan değer
    this.recordedAt,
  });

  factory SensorData.fromRecord(RecordModel record) {
    return SensorData(
      temperature: record.getDoubleValue('temp_c'),
      humidity: record.getDoubleValue('rh_percent'),
      co2: record.getIntValue('co2_ppm'),
      gas: record.getIntValue('voc_index'),
      comfortScore: record.getDoubleValue('comfort_score'),
      isOccupied: record.getBoolValue('pir_occupied'), // Veritabanı şemasından al
      recordedAt: DateTime.parse(record.getStringValue('recorded_at')),
    );
  }

  factory SensorData.empty() {
    return SensorData(
      temperature: 0,
      humidity: 0,
      co2: 0,
      gas: 0,
      comfortScore: 0,
      isOccupied: false,
    );
  }
}