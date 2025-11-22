import 'package:pocketbase/pocketbase.dart';
import '../../../core/pb_client.dart';

class SensorRepository {
  final PocketBase _pb = PbClient.I.client;

  Future<List<RecordModel>> getLatestReadings({
    required int limit,
    String? placeId,
  }) async {
    final result = await _pb.collection('sensor_readings').getList(
          page: 1,
          perPage: limit,
          sort: '-recorded_at',
          filter: placeId != null ? 'place_id = "$placeId"' : null,
        );

    return result.items;
  }

  Future<UnsubscribeFunc> subscribeSensorReadings(
      RecordSubscriptionFunc callback) {
    return _pb.collection('sensor_readings').subscribe('*', callback);
  }
}
