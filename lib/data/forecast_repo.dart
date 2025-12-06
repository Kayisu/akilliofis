import 'dart:math'; 
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';
import 'forecast_model.dart';

class ForecastRepo {
  final PocketBase _pb = PbClient.I.client;

  /// Belirtilen odaya ait gelecekteki tahminleri çeker.
  Future<List<ForecastModel>> getWeeklyForecasts(String placeId) async {
    try {
      // TODO: regresyon hazır olana kadar mock data 
      const bool useMock = true; 
      
      if (useMock) {
       
        return _generateMockForecasts(placeId);
      }

      // useMock her zaman true oldugu ıcın else calısmıor ama veri çekerken lazım olcak
      // ignore: dead_code
      final now = DateTime.now().toUtc().toIso8601String();
      
      final records = await _pb.collection('forecasts').getFullList(
        filter: 'place_id = "$placeId" && target_ts >= "$now"',
        sort: 'target_ts',
      );

      return records.map((e) => ForecastModel.fromRecord(e)).toList();

    } catch (e) {
      debugPrint('Tahmin verisi çekilemedi: $e');
      return _generateMockForecasts(placeId); 
    }
  }

  // Mock veri üretici (Değişiklik yok)
  List<ForecastModel> _generateMockForecasts(String placeId) {
    List<ForecastModel> mocks = [];
    final now = DateTime.now();
    final random = Random();

    for (int day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      final hours = [9, 11, 13, 15, 17];
      
      for (int hour in hours) {
        double baseOccupancy = (hour >= 11 && hour <= 14) ? 60.0 : 30.0;
        double noise = random.nextDouble() * 40.0;
        double occupancy = (baseOccupancy + noise).clamp(0.0, 100.0);

        double comfort = 1.0 - (occupancy / 150.0) - (random.nextDouble() * 0.1);
        comfort = comfort.clamp(0.0, 1.0);

        mocks.add(ForecastModel(
          placeId: placeId,
          targetTs: DateTime(date.year, date.month, date.day, hour),
          predictedOccupancy: double.parse(occupancy.toStringAsFixed(1)),
          predictedComfort: double.parse(comfort.toStringAsFixed(2)),
        ));
      }
    }
    return mocks;
  }
}