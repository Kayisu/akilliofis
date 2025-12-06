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
    final records = await _pb.collection('reservations').getFullList(
      // Sadece iptal edilmemişleri (pending, approved) getir ki liste temiz kalsın
      filter: 'user_id = "$userId" && status != "cancelled"',
      sort: '-start_ts',
      expand: 'place_id',
    );
    return records.map((e) => ReservationModel.fromRecord(e)).toList();
  }

  Future<List<ReservationModel>> getAdminReservations({String? filterStatus}) async {
    String filter = 'status != "cancelled"'; // İptalleri admin de görmesin (veya görsün istersen sil)
    
    if (filterStatus != null) {
      filter += ' && status = "$filterStatus"';
    }

    final records = await _pb.collection('reservations').getFullList(
      filter: filter,
      sort: '-start_ts', // En yeni en üstte
      expand: 'place_id,user_id', // Hem odayı hem kullanıcıyı çekiyoruz
    );
    
    return records.map((e) => ReservationModel.fromRecord(e)).toList();
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final body = {
      'status': newStatus,
    };
    await _pb.collection('reservations').update(id, body: body);
  }

  Future<void> cancelReservation(String id) async {
    final body = {
      'status': 'cancelled', // Statüyü 'cancelled' yapıyoruz
    };
    await _pb.collection('reservations').update(id, body: body);
  }

  Future<void> deleteReservation(String id) async {
    await _pb.collection('reservations').delete(id);
  }
}