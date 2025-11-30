class ReservationModel {
  final String? id;
  final String placeId;
  final String userId;
  final DateTime startTs;
  final DateTime endTs;
  final String status;
  
  // Ekstra: İlişkisel veriler (Expand)
  final String? placeName; 

  ReservationModel({
    this.id,
    required this.placeId,
    required this.userId,
    required this.startTs,
    required this.endTs,
    this.status = 'pending',
    this.placeName,
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
    // PocketBase RecordModel veya JSON map gelebilir
    final data = record is Map<String, dynamic> ? record : record.data;
    final String rId = record is Map<String, dynamic> ? record['id'] : record.id;
    
    // Expand verisini güvenli şekilde çekme
    String? pName;
    if (record.expand != null && record.expand.containsKey('place_id')) {
      final placeData = record.expand['place_id'];
      if (placeData is List && placeData.isNotEmpty) {
        pName = placeData.first.data['name']; // RecordModel listesi döner
      } else if (placeData is Map) { // Bazen tekil obje dönebilir
        pName = placeData['name'];
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
    );
  }
}