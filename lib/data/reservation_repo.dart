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

  // YENİ: İptal Etme (Soft Delete)
  Future<void> cancelReservation(String id) async {
    final body = {
      'status': 'cancelled', // Statüyü 'cancelled' yapıyoruz
    };
    await _pb.collection('reservations').update(id, body: body);
  }
}