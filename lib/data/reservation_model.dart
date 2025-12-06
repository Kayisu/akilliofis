class ReservationModel {
  final String? id;
  final String placeId;
  final String userId;
  final DateTime startTs;
  final DateTime endTs;
  final String status;
  final String? placeName; 
  final String? userName;

  ReservationModel({
    this.id,
    required this.placeId,
    required this.userId,
    required this.startTs,
    required this.endTs,
    this.status = 'pending',
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
    };
  }

  factory ReservationModel.fromRecord(dynamic record) {
    final data = record is Map<String, dynamic> ? record : record.data;
    final String rId = record is Map<String, dynamic> ? record['id'] : record.id;
    
    // Expand verisini güvenli şekilde çekme
    String? pName;
    if (record.expand != null && record.expand.containsKey('place_id')) {
      final placeData = record.expand['place_id'];
      if (placeData is List && placeData.isNotEmpty) {
        pName = placeData.first.data['name'];
      } else if (placeData is Map) {
        pName = placeData['name'];
      }
    }

    String? uName;
    if (record.expand != null && record.expand.containsKey('user_id')) {
      final userData = record.expand['user_id'];
      if (userData is List && userData.isNotEmpty) {
        uName = userData.first.data['fullName'];
      } else if (userData is Map) {
        uName = userData['fullName'];
      }
    }

    return ReservationModel(
      id: rId,
      placeId: data['place_id'] ?? '',
      userId: data['user_id'] ?? '',
      startTs: DateTime.parse(data['start_ts']),
      endTs: DateTime.parse(data['end_ts']),
      status: data['status'] ?? 'pending',
      placeName: pName,
      userName: uName,
    );
  }
}