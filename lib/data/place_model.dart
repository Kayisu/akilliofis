import 'package:pocketbase/pocketbase.dart';

class PlaceModel {
  final String id;
  final String name;
  final int capacity;
  final bool isActive; // Yeni eklenen alan

  PlaceModel({
    required this.id,
    required this.name,
    required this.capacity,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'capacity': capacity,
      'is_active': isActive, // DB'ye gönderirken snake_case
    };
  }

  factory PlaceModel.fromRecord(RecordModel record) {
    return PlaceModel(
      id: record.id,
      name: record.data['name'] ?? '',
      capacity: record.data['capacity'] ?? 0,
      isActive: record.data['is_active'] ?? true, // DB'den okurken
    );
  }
}