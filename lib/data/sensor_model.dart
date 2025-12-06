import 'package:pocketbase/pocketbase.dart';

class SensorData {
  final double temperature;
  final double humidity;
  final int co2;
  final int gas; // VOC Index
  final double comfortScore;
  final DateTime? recordedAt;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.gas,
    required this.comfortScore,
    this.recordedAt,
  });

  // PocketBase kaydından (record) model oluşturma
  factory SensorData.fromRecord(RecordModel record) {
    return SensorData(
      temperature: record.getDoubleValue('temp_c'),
      humidity: record.getDoubleValue('rh_percent'),
      co2: record.getIntValue('co2_ppm'),
      // voc_index genelde 0-500 arasıdır, int olarak alabiliriz
      gas: record.getIntValue('voc_index'), 
      comfortScore: record.getDoubleValue('comfort_score'),
      recordedAt: DateTime.parse(record.getStringValue('recorded_at')),
    );
  }

  // Veri yoksa gösterilecek boş durum
  factory SensorData.empty() {
    return SensorData(
      temperature: 0,
      humidity: 0,
      co2: 0,
      gas: 0,
      comfortScore: 0,
    );
  }
}