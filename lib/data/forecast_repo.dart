import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';
import 'forecast_model.dart';

class ForecastRepo {
  final PocketBase _pb = PbClient.I.client;

  // Metot ismi senin çağırdığın 'getWeeklyForecasts' olarak güncellendi
  Future<List<ForecastModel>> getWeeklyForecasts(String placeId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    
    // Geleceğe dönük tahminleri çekiyoruz
    final records = await _pb.collection('forecasts').getFullList(
      filter: 'place_id = "$placeId" && target_ts >= "$now"',
      sort: 'target_ts', // Tarihe göre sırala (En yakın en üstte)
    );

    return records.map((e) => ForecastModel.fromRecord(e)).toList();
  }
}