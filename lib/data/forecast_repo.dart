//forecast_repo.dart
import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';
import 'forecast_model.dart';

class ForecastRepo {
  final PocketBase _pb = PbClient.I.client;

  // Haftalık tahminleri getiren metot
  Future<List<ForecastModel>> getWeeklyForecasts(String placeId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    
    // Gelecek tarihli tahmin verilerini getir
    final records = await _pb.collection('forecasts').getFullList(
      filter: 'place_id = "$placeId" && target_ts >= "$now"',
      sort: 'target_ts', // Tarihe göre sırala (Yakından uzağa)
    );

    return records.map((e) => ForecastModel.fromRecord(e)).toList();
  }
}