import 'package:flutter/foundation.dart'; // debugPrint için gerekli
import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';
import 'sensor_model.dart';

class SensorRepository {
  final PocketBase _pb = PbClient.I.client;

  /// Belirtilen odaya (placeId) ait EN SON sensör verisini çeker.
  Future<SensorData> getLatestSensorData(String placeId) async {
    try {
      // 'sensor_readings' koleksiyonundan, place_id'si eşleşen
      // 'created' tarihine göre en yeni (descending) 1 kaydı getir.
      final records = await _pb.collection('sensor_readings').getList(
        page: 1,
        perPage: 1,
        filter: 'place_id = "$placeId"',
        sort: '-created', 
      );

      if (records.items.isNotEmpty) {
        return SensorData.fromRecord(records.items.first);
      } else {
        // Kayıt yoksa boş model dön
        return SensorData.empty();
      }
    } catch (e) {
      // Hata durumunda (loglayabilirsin) boş dönelim ki uygulama çökmesin
      debugPrint('Sensör verisi çekilemedi: $e');
      return SensorData.empty();
    }
  }
}