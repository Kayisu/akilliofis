//sensor_repo.dart
import 'dart:async';
import 'package:flutter/foundation.dart'; 
import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';
import 'sensor_model.dart';

class SensorRepository {
  final PocketBase _pb = PbClient.I.client;

  //Belirtilen odaya ait en son sensör verisini getir
  Future<SensorData> getLatestSensorData(String placeId) async {
    try {
      // Sensör okumaları koleksiyonundan odaya göre filtrele
      // Oluşturulma tarihine göre en yeni kaydı al
      final records = await _pb.collection('sensor_readings').getList(
        page: 1,
        perPage: 1,
        filter: 'place_id = "$placeId"',
        sort: '-created', 
      );

      if (records.items.isNotEmpty) {
        return SensorData.fromRecord(records.items.first);
      } else {
        // Kayıt bulunamazsa boş model döndür
        return SensorData.empty();
      }
    } catch (e) {
      // Hata durumunda uygulamanın çökmemesi için boş değer dön
      debugPrint('Sensör verisi çekilemedi: $e');
      return SensorData.empty();
    }
  }

  Stream<SensorData> subscribeToPlace(String placeId) {
    final controller = StreamController<SensorData>();

    // İlk veriyi yükle
    getLatestSensorData(placeId).then((data) {
      if (!controller.isClosed) controller.add(data);
    });

    // Abonelik değişikliği: Filtreleme istemci tarafında yapılıyor
    _pb.collection('sensor_readings').subscribe('*', (e) {
      // 1. Sadece yeni kayıt oluşturma işlemleri
      if (e.action == 'create' && e.record != null) {
        
        // 2. İstemci tarafı filtreleme:
        // Veri izlenen odaya mı ait?
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
          .reversed // Eskiden yeniye doğru sırala
          .toList();
          
    } catch (e) {
      debugPrint('Geçmiş veri alınırken hata oluştu: $e');
      return [];
    }
  }
}