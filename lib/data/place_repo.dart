//place_repo.dart
import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';
import 'place_model.dart';

class PlaceRepo {
  final PocketBase _pb = PbClient.I.client;

  Future<List<PlaceModel>> getPlaces() async {
    // Yönetici tüm odaları (aktif/pasif) görebilir
    final records = await _pb.collection('places').getFullList(
      sort: 'name',
    );
    return records.map((e) => PlaceModel.fromRecord(e)).toList();
  }

  // Kullanıcılar için sadece aktif odaları listele
  Future<List<PlaceModel>> getActivePlaces() async {
    final records = await _pb.collection('places').getFullList(
      filter: 'is_active = true',
      sort: 'name',
    );
    return records.map((e) => PlaceModel.fromRecord(e)).toList();
  }

  Future<void> createPlace(PlaceModel place) async {
    await _pb.collection('places').create(body: place.toJson());
  }

  Future<void> updatePlace(PlaceModel place) async {
    await _pb.collection('places').update(place.id, body: place.toJson());
  }

  Future<void> deletePlace(String id) async {
    await _pb.collection('places').delete(id);
  }
}