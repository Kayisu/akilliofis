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
    // İptal edilenleri gösterme (status != cancelled)
    // Kullanıcının gizlediklerini gösterme (is_hidden = false)
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
      // Eğer özel bir durum isteniyorsa (örn: sadece pending) onu filtrele
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

  // Kullanıcı "İptal Et" dediğinde bu çalışacak (Soft Delete)
  Future<void> hideReservation(String id) async {
    final body = { 'is_hidden': true };
    await _pb.collection('reservations').update(id, body: body);
  }

  Future<void> cancelReservation(String id) async {
    final body = { 'status': 'cancelled' };
    await _pb.collection('reservations').update(id, body: body);
  }
  
  // deleteReservation'a artık kullanıcının ihtiyacı yok, ama admin için durabilir.
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
    
    // Süresi dolmuş ama hala "pending" veya "approved" olanları bul
    final filter = 'end_ts < "$nowStr" && (status = "pending" || status = "approved")';

    try {
      final records = await _pb.collection('reservations').getFullList(filter: filter);
      
      for (var record in records) {
        String newStatus;
        
        // MANTIK: 
        // Eğer süresi dolana kadar 'pending' (beklemede) kaldıysa -> REJECTED (Zaman aşımı)
        // Eğer 'approved' (onaylı) ise -> COMPLETED (Başarıyla tamamlandı)
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