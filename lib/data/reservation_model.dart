//reservation_model.dart
import 'package:pocketbase/pocketbase.dart';

class ReservationModel {
  final String? id;
  final String placeId;
  final String userId;
  final DateTime startTs;
  final DateTime endTs;
  final String status;
  final bool isHidden;
  final int attendeeCount; // Katılımcı sayısı

  // İlişkili kayıtlardan gelen detaylar
  final String? placeName;
  final String? userName;

  ReservationModel({
    this.id,
    required this.placeId,
    required this.userId,
    required this.startTs,
    required this.endTs,
    this.status = 'pending',
    this.isHidden = false,
    this.attendeeCount = 1, // Varsayılan olarak 1 kişi
    this.placeName,
    this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'user_id': userId,
      'start_ts': startTs.toUtc().toIso8601String(),
      'end_ts': endTs.toUtc().toIso8601String(),
      'status': status,
      'is_hidden': isHidden,
      'attendee_count': attendeeCount,
    };
  }

  factory ReservationModel.fromRecord(RecordModel record) {
    final expand = record.expand;
    String? pName;
    String? uName;

    if (expand.containsKey('place_id')) {
      final places = expand['place_id'] as List<RecordModel>;
      if (places.isNotEmpty) pName = places.first.data['name'];
    }
    
    if (expand.containsKey('user_id')) {
      final users = expand['user_id'] as List<RecordModel>;
      if (users.isNotEmpty) uName = users.first.data['fullName'];
    }

    return ReservationModel(
      id: record.id,
      placeId: record.data['place_id'] ?? '',
      userId: record.data['user_id'] ?? '',
      // Saatleri sunucudan alır almaz yerel saate çeviriyoruz
      startTs: DateTime.parse(record.data['start_ts']).toLocal(),
      endTs: DateTime.parse(record.data['end_ts']).toLocal(),
      
      status: record.data['status'] ?? 'pending',
      isHidden: record.data['is_hidden'] ?? false,
      attendeeCount: record.data['attendee_count'] ?? 1,
      placeName: pName,
      userName: uName,
    );
  }
}