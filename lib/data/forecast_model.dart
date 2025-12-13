import 'package:pocketbase/pocketbase.dart';

class ForecastModel {
  final String id;
  final String placeId;
  final DateTime targetTs;
  // İsimlendirmeler senin grafik koduna uyduruldu
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
      // PocketBase'den gelen String tarihi DateTime'a çeviriyoruz
      targetTs: DateTime.parse(record.getStringValue('target_ts')),
      // PocketBase sütun isimleri ile eşleştiriyoruz
      predictedOccupancy: record.getDoubleValue('predicted_occupancy'),
      predictedComfort: record.getDoubleValue('predicted_comfort_score'),
    );
  }
}