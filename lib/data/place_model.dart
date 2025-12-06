import 'package:pocketbase/pocketbase.dart';

class PlaceModel {
  final String id;
  final String name;
  final int capacity;
  final bool isActive;
  final String created;

  PlaceModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.isActive,
    required this.created,
  });

  factory PlaceModel.fromRecord(RecordModel record) {
    return PlaceModel(
      id: record.id,
      name: record.getStringValue('name'),
      capacity: record.getIntValue('capacity'),
      isActive: record.getBoolValue('is_active'),
      created: record.created,
    );
  }
}
