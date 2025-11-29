import 'package:pocketbase/pocketbase.dart';
import '../core/pb_client.dart';
import 'place_model.dart';

class PlaceRepo {
  final PocketBase _pb = PbClient.I.client;

  Future<List<PlaceModel>> getPlaces() async {
    final records = await _pb.collection('places').getFullList(
      sort: 'created',
    );
    return records.map((e) => PlaceModel.fromRecord(e)).toList();
  }
}
