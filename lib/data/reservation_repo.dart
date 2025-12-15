import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';
import 'reservation_model.dart';

class ReservationRepo {
  final PocketBase _pb = PbClient.I.client;

  Future<RecordModel> createReservation(ReservationModel reservation) async {
    return await _pb.collection('reservations').create(
      body: reservation.toJson(),
    );
  }

  Future<List<ReservationModel>> getMyReservations(String userId) async {
    // İptal edilen rezervasyonları hariç tut
    // Kullanıcı tarafından gizlenenleri gösterme
    final records = await _pb.collection('reservations').getFullList(
      filter: 'user_id = "$userId" && status != "cancelled" && is_hidden = false',
      sort: '-start_ts',
      expand: 'place_id',
    );
    return records.map((e) => ReservationModel.fromRecord(e)).toList();
  }

  Future<List<ReservationModel>> getAdminReservations({String? filterStatus}) async {
    String filter = ''; 
    
    if (filterStatus != null) {
      // Belirli bir duruma göre filtreleme yap
      filter = 'status = "$filterStatus"';
    }

    final records = await _pb.collection('reservations').getFullList(
      filter: filter.isNotEmpty ? filter : null,
      sort: '-start_ts', 
      expand: 'place_id,user_id', 
    );
    
    return records.map((e) => ReservationModel.fromRecord(e)).toList();
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final body = { 'status': newStatus };
    await _pb.collection('reservations').update(id, body: body);
  }

  // Kullanıcı iptali (Görünürlüğü gizle)
  Future<void> hideReservation(String id) async {
    final body = { 'is_hidden': true };
    await _pb.collection('reservations').update(id, body: body);
  }

  Future<void> cancelReservation(String id) async {
    final body = { 'status': 'cancelled' };
    await _pb.collection('reservations').update(id, body: body);
  }
  
  // Rezervasyonu tamamen sil (Yönetici işlemi)
  Future<void> deleteReservation(String id) async {
    await _pb.collection('reservations').delete(id);
  }

  Future<bool> checkOverlap(String placeId, DateTime start, DateTime end) async {
    final startStr = start.toUtc().toIso8601String();
    final endStr = end.toUtc().toIso8601String();

    final filter = 
      'place_id = "$placeId" && '
      'status != "cancelled" && status != "rejected" && status != "completed" && '
      'start_ts < "$endStr" && end_ts > "$startStr"';

    final result = await _pb.collection('reservations').getList(
      page: 1, perPage: 1, filter: filter,
    );
    return result.items.isNotEmpty;
  }

  Future<void> processExpiredReservations() async {
    final nowStr = DateTime.now().toUtc().toIso8601String();
    
    // Süresi dolmuş ve işlem bekleyen rezervasyonları bul
    final filter = 'end_ts < "$nowStr" && (status = "pending" || status = "approved")';

    try {
      final records = await _pb.collection('reservations').getFullList(filter: filter);
      
      for (var record in records) {
        String newStatus;
        
        // İşlem mantığı:
        // Beklemede kalanlar -> Reddedildi (Zaman aşımı)
        // Onaylı olanlar -> Tamamlandı
        if (record.data['status'] == 'pending') {
          newStatus = 'rejected';
        } else {
          newStatus = 'completed';
        }

        await _pb.collection('reservations').update(record.id, body: {'status': newStatus});
      }
    } catch (e) {
      print("Expire check error: $e");
    }
  }
}