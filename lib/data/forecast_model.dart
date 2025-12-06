import 'package:pocketbase/pocketbase.dart';

class ForecastModel {
  final String placeId;
  final DateTime targetTs;
  final double predictedOccupancy;
  final double predictedComfort;

  ForecastModel({
    required this.placeId,
    required this.targetTs,
    required this.predictedOccupancy,
    required this.predictedComfort,
  });

  factory ForecastModel.fromRecord(RecordModel record) {
    return ForecastModel(
      placeId: record.getStringValue('place_id'),
      targetTs: DateTime.parse(record.getStringValue('target_ts')),
      predictedOccupancy: record.getDoubleValue('predicted_occupancy'),
      predictedComfort: record.getDoubleValue('predicted_comfort_score'),
    );
  }
}