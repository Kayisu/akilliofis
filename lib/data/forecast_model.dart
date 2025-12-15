import 'package:pocketbase/pocketbase.dart';

class ForecastModel {
  final String id;
  final String placeId;
  final DateTime targetTs;
  // Grafik kodlarıyla uyumlu isimlendirmeler
  final double predictedOccupancy; 
  final double predictedComfort; 

  ForecastModel({
    required this.id,
    required this.placeId,
    required this.targetTs,
    required this.predictedOccupancy,
    required this.predictedComfort,
  });

  factory ForecastModel.fromRecord(RecordModel record) {
    return ForecastModel(
      id: record.id,
      placeId: record.getStringValue('place_id'),
      // Sunucudan gelen tarih verisini dönüştür
      targetTs: DateTime.parse(record.getStringValue('target_ts')),
      // Veritabanı sütun isimleriyle eşleştirme
      predictedOccupancy: record.getDoubleValue('predicted_occupancy'),
      predictedComfort: record.getDoubleValue('predicted_comfort_score'),
    );
  }
}