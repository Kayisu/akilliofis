import 'dart:async';
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

  Stream<SensorData> subscribeToPlace(String placeId) {
    final controller = StreamController<SensorData>();

    // Başlangıç verisi
    getLatestSensorData(placeId).then((data) {
      if (!controller.isClosed) controller.add(data);
    });

    // SUBSCRIBE DEĞİŞİKLİĞİ: filter parametresi kaldırıldı, mantık içeri alındı.
    _pb.collection('sensor_readings').subscribe('*', (e) {
      // 1. Sadece 'create' aksiyonu mu?
      if (e.action == 'create' && e.record != null) {
        
        // 2. İSTEMCİ TARAFI FİLTRELEME:
        // Gelen veri bizim izlediğimiz odaya mı ait?
        if (e.record!.data['place_id'] == placeId) {
          if (!controller.isClosed) {
            controller.add(SensorData.fromRecord(e.record!));
          }
        }
      }
    });

    controller.onCancel = () {
      _pb.collection('sensor_readings').unsubscribe('*');
    };

    return controller.stream;
  }

  Future<List<SensorData>> getHistory(String placeId, {int limit = 300}) async {
    try {
      final records = await _pb.collection('sensor_readings').getList(
        page: 1, 
        perPage: limit,
        filter: 'place_id = "$placeId"',
        sort: '-created', 
      );
      
      return records.items
          .map((e) => SensorData.fromRecord(e))
          .toList()
          .reversed // Eskiden yeniye sırala
          .toList();
          
    } catch (e) {
      debugPrint('Geçmiş veri hatası: $e');
      return [];
    }
  }
}